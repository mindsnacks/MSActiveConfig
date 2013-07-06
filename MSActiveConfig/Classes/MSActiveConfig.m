//
//  MSActiveConfig.m
//  MSActiveConfig
//
//  Created by Javier Soto on 6/26/12.
//  Copyright (c) 2012 MindSnacks. All rights reserved.
//

#import "MSActiveConfig.h"
#import "MSActiveConfig+Private.h"

#import "MSActiveConfigSection.h"
#import "MSActiveConfigSection+Private.h"

#import "MSActiveConfigConfigurationState.h"
#import "MSActiveConfigMutableConfigurationState.h"
#import "MSActiveConfigStore.h"

#import "MSActiveConfigDownloader.h"

#if !__has_feature(objc_arc)
#error MSActiveConfig requires being compiled with ARC on.
#endif

static NSString *const MSActiveConfigFirstDownloadFinishedUserDefaultsKey = @"com_mindsnacks_activeconfig_firstdownloadfinished";

#define MSActiveConfigEqualUserIDs(UserID1, UserID2) ((UserID1 == UserID2) || ([UserID1 isEqual:UserID2]))

NSString *const MSActiveConfigFirstDownloadFinishedNotification = @"MSActiveConfigFirstDownloadFinishedNotification";
NSString *const MSActiveConfigDownloadUpdateFinishedNotification = @"MSActiveConfigDownloadUpdateFinishedNotification";
NSString *const MSActiveConfigDownloadUpdateFinishedNotificationUserIDKey = @"user_id";
NSString *const MSActiveConfigDownloadUpdateFinishedNotificationMetaKey = @"meta";
NSString *const MSActiveConfigDownloadUpdateFinishedNotificationConfigurationIsCurrentKey = @"config_was_set";

@interface MSActiveConfig()

/**
 * { sectionName : [NSHashTable] listeners for that section name }
 */
@property (nonatomic, readonly, strong) NSMutableDictionary *listeners;

@property (nonatomic, readwrite, strong) id<MSActiveConfigDownloader> configDownloader;
@property (nonatomic, readwrite, strong) id<MSActiveConfigStore> configStore;

@property (nonatomic, readwrite, strong) NSMutableSet *currentlyDownloadingUserIDs;

@property (nonatomic, readwrite, strong) dispatch_queue_t privateQueue;

@property (atomic, readwrite, assign) BOOL firstConfigDownloadFinished;

@property (nonatomic, strong) dispatch_queue_t downloaderQueue;

@end

@implementation MSActiveConfig

@synthesize currentUserID = _currentUserID;
@synthesize firstConfigDownloadFinished = _firstConfigDownloadFinished;

- (id)initWithConfigDownloader:(id<MSActiveConfigDownloader>)downloader
                   configStore:(id<MSActiveConfigStore>)store
{
    NSParameterAssert(downloader);

    if ((self = [super init]))
    {
        _listeners = [[NSMutableDictionary alloc] init];
        self.configDownloader = downloader;
        self.configStore = store;

        self.privateQueue = dispatch_queue_create("com.mindsnacks.activeconfig", DISPATCH_QUEUE_SERIAL);
        self.downloaderQueue = dispatch_queue_create("com.mindsnacks.activeconfig.downloader", DISPATCH_QUEUE_CONCURRENT);
        self.listenerNotificationsQueue = dispatch_get_main_queue();

        self.currentlyDownloadingUserIDs = [NSMutableSet set];
        _firstConfigDownloadFinished = [[NSUserDefaults standardUserDefaults] boolForKey:MSActiveConfigFirstDownloadFinishedUserDefaultsKey];

        _configurationState = [[MSActiveConfigMutableConfigurationState alloc] init];

        [self loadLastKnownActiveConfigurationForUserID:nil];
    }

    return self;
}

- (id)init
{
    return [self initWithConfigDownloader:nil
                              configStore:nil];
}

#pragma mark - Private Methods

/**
 * @param isLastKnownConfiguration whether it's just setting the initial state. If YES, it won't automatically persist the new state.
 */
- (void)setNewConfigState:(MSActiveConfigConfigurationState *)newConfigurationState
                forUserID:(NSString *)userID
 isLastKnownConfiguration:(BOOL)isLastKnownConfiguration
{
    if (newConfigurationState)
    {
        @synchronized(self)
        {
            __block BOOL anyValueChanged = NO;

            self.configurationState.formatVersion = newConfigurationState.formatVersion;
            self.configurationState.creationDateString = newConfigurationState.creationDateString;
            self.configurationState.meta = newConfigurationState.meta;

            NSDictionary *configDictionary = newConfigurationState.configurationDictionary;

            [configDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *sectionName, NSDictionary *configValue, BOOL *stop) {
                NSDictionary *currentValue = [self.configDictionary valueForKey:sectionName];

                const BOOL configValueIsValid = [configValue isKindOfClass:[NSDictionary class]];

                if (!configValueIsValid)
                {
                    configValue = [NSDictionary dictionary];
                }

                const BOOL valueChanged = (!currentValue || ![currentValue isEqualToDictionary:configValue]);
                if (valueChanged)
                {
                    anyValueChanged = YES;

                    [self.configDictionary setValue:configValue forKey:sectionName];

                    if (MSActiveConfigEqualUserIDs(userID, self.currentUserID))
                    {
                        [self notifyConfigUpdateForSection:sectionName];
                    }
                }
            }];

            NSMutableSet *removedKeys = [NSMutableSet setWithArray:self.configDictionary.allKeys];
            [removedKeys minusSet:[NSSet setWithArray:configDictionary.allKeys]];

            [removedKeys enumerateObjectsUsingBlock:^(NSString *gonesectionName, BOOL *stop) {
                anyValueChanged = YES;

                [self.configDictionary removeObjectForKey:gonesectionName];

                if (MSActiveConfigEqualUserIDs(userID, self.currentUserID))
                {
                    [self notifyConfigUpdateForSection:gonesectionName];
                }
            }];

            if (!isLastKnownConfiguration && anyValueChanged)
            {
                dispatch_async(self.privateQueue, ^{
                    [self.configStore persistConfiguration:self.configurationState forUserID:userID];
                });
            }
        }
    }
    else
    {
        NSLog(@"ActiveConfig: trying to set a nil configuration state. Ignoring it.");
    }
}

- (void)setNewConfigState:(MSActiveConfigConfigurationState *)newConfigurationState
                forUserID:(NSString *)userID
{
    [self setNewConfigState:newConfigurationState
                  forUserID:userID
   isLastKnownConfiguration:NO];
}

- (NSString *)currentUserID
{
    @synchronized(self)
    {
        return _currentUserID;
    }
}

- (void)setCurrentUserID:(NSString *)currentUserID
{
    @synchronized(self)
    {
        if (currentUserID != _currentUserID)
        {
            _currentUserID = currentUserID;

            [self loadLastKnownActiveConfigurationForUserID:currentUserID];
        }
    }
}

- (void)loadLastKnownActiveConfigurationForUserID:(NSString *)userID
{
    dispatch_sync(self.privateQueue, ^{
        [self setNewConfigState:[[self.configStore lastKnownActiveConfigurationForUserID:userID] mutableCopy]
                      forUserID:userID
       isLastKnownConfiguration:YES];
    });
}

- (void)downloadNewConfig
{
    dispatch_async(self.privateQueue, ^{
        NSString *userIDToRequest = self.currentUserID;
        if (![self isCurrentlyDownloadingConfigForUserID:userIDToRequest])
        {
            [self setDownloadInProgress:YES forUserID:userIDToRequest];

            dispatch_async(self.downloaderQueue, ^{
                NSError *error = nil;
                NSDictionary *newConfig = [self.configDownloader requestActiveConfigForUserWithID:userIDToRequest
                                                                                            error:&error];

                dispatch_async(self.privateQueue, ^{
                    [self setDownloadInProgress:NO forUserID:userIDToRequest];

                    BOOL requestSucceeded = (error == nil);

                    if (requestSucceeded)
                    {
                        [self downloadNewConfigFinishedSuccessfullyForUserID:userIDToRequest
                                                     configurationDictionary:newConfig];
                    }
                    else
                    {
                        NSLog(@"Request for MSActiveConfig failed with error: %@", error);
                    }
                });
            });
        }
        else
        {
            NSLog(@"Skipping downloading Active Config for user ID %@ because there's already a download in progress", userIDToRequest ?: @"0");
        }
    });
}

/**
 * @discussion must call from the private queue
 */
- (void)downloadNewConfigFinishedSuccessfullyForUserID:(NSString *)userID
                               configurationDictionary:(NSDictionary *)configurationDictionary
{
    const BOOL sameUserID = MSActiveConfigEqualUserIDs(self.currentUserID, userID);

    MSActiveConfigConfigurationState *newState = [[MSActiveConfigConfigurationState alloc] initWithDictionary:configurationDictionary];

    if (newState && newState.configurationDictionary.count > 0)
    {
        if (sameUserID)
        {
            [self setNewConfigState:newState
                          forUserID:userID];

            if (!self.firstConfigDownloadFinished)
            {
                self.firstConfigDownloadFinished = YES;

                dispatch_async(self.listenerNotificationsQueue, ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:MSActiveConfigFirstDownloadFinishedNotification
                                                                        object:self];
                });
            };
        }
        else
        {
            // The user has changed during the download, just persist it the downloaded config.
            [self.configStore persistConfiguration:newState
                                         forUserID:userID];
        }
    }
    else
    {
        NSLog(@"Failed to create %@ object with configuration dictionary %@", NSStringFromClass([MSActiveConfigConfigurationState class]), configurationDictionary);
    }

    // Send a notification regardless. If the downloader returns an empty response but there was no error, it may mean nothing has changed.
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:MSActiveConfigDownloadUpdateFinishedNotification
                                                            object:self
                                                          userInfo:
         (@{
          MSActiveConfigDownloadUpdateFinishedNotificationUserIDKey : userID ?: [NSNull null],
          MSActiveConfigDownloadUpdateFinishedNotificationMetaKey : newState.meta ?: self.currentConfigurationMetaDictionary ?: @{},
          MSActiveConfigDownloadUpdateFinishedNotificationConfigurationIsCurrentKey: @(newState != nil && sameUserID)
          })];
    });
}

- (void)notifyListener:(id<MSActiveConfigListener>)listener
        forSectionName:(NSString *)sectionName
     withConfigSection:(MSActiveConfigSection *)configSection
{
    dispatch_async(self.listenerNotificationsQueue, ^{
        [listener activeConfig:self
       didReceiveConfigSection:configSection
                forSectionName:sectionName];
    });
}

- (void)notifyListener:(id<MSActiveConfigListener>)listener forSectionName:(NSString *)sectionName
{
    @synchronized(self)
    {
        MSActiveConfigSection *configSection = [self.configurationState configSectionWithName:sectionName];

        [self notifyListener:listener
              forSectionName:sectionName
           withConfigSection:configSection];
    }
}

/**
 * @discussion private method, only called from within the private queue.
 */
- (void)notifyConfigUpdateForSection:(NSString *)sectionName
{
    NSArray *interestedListeners = [[self.listeners valueForKey:sectionName] allObjects];

    for (id<MSActiveConfigListener> listener in interestedListeners)
    {
        [self notifyListener:listener
              forSectionName:sectionName];
    }
}

#pragma mark - Public Methods

- (void)registerListener:(id<MSActiveConfigListener>)listener forSectionName:(NSString *)sectionName
{
    NSParameterAssert(listener);
    NSParameterAssert(sectionName);

    @synchronized(self)
    {
        NSHashTable *listenersForKey = [self.listeners objectForKey:sectionName];

        BOOL existingListenersArray = YES;

        if (!listenersForKey)
        {
            existingListenersArray = NO;
            listenersForKey = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPointerPersonality];
        }

        [listenersForKey addObject:listener];

        if (!existingListenersArray)
        {
            [self.listeners setObject:listenersForKey forKey:sectionName];
        }

        MSActiveConfigSection *currentConfigSectionForProvidedKey = [self configSectionWithName:sectionName];

        // Send the notification of the current settings
        if (currentConfigSectionForProvidedKey)
        {
            [self notifyListener:listener
                  forSectionName:sectionName
               withConfigSection:currentConfigSectionForProvidedKey];
        }
    }
}

- (void)removeListener:(id<MSActiveConfigListener>)listener forSectionName:(NSString *)sectionName
{
    NSParameterAssert(listener);
    NSParameterAssert(sectionName);

    // This needs to happen synchronously in the caller thread because it could be called from -dealloc.
    // We also must not strong the listener object.

    @synchronized(self)
    {
        NSHashTable *listenersForKey = [self.listeners objectForKey:sectionName];

        [listenersForKey removeObject:listener];
    }
}

- (MSActiveConfigSection *)configSectionWithName:(NSString *)sectionName
{
    NSDictionary *configurationDictionary = nil;

    @synchronized(self)
    {
        configurationDictionary = [self.configDictionary valueForKey:sectionName];
    }

    if (configurationDictionary)
    {
        return [[MSActiveConfigSection alloc] initWithDictionary:configurationDictionary];
    }
    else
    {
        return nil;
    }
}

- (MSActiveConfigSection *)objectForKeyedSubscript:(NSString *)sectionName
{
    return [self configSectionWithName:sectionName];
}

- (NSDictionary *)currentConfigurationMetaDictionary
{
    @synchronized(self)
    {
        return self.configurationState.meta;
    }
}

#pragma mark - Simultaneous Download Handling

- (NSString *)stringToUseForUserID:(NSString *)userID
{
    return userID ?: (id)[NSNull null];
}

- (BOOL)isCurrentlyDownloadingConfigForUserID:(NSString *)userID
{
    @synchronized(self.currentlyDownloadingUserIDs)
    {
        return [self.currentlyDownloadingUserIDs containsObject:[self stringToUseForUserID:userID]];
    }
}

- (void)setDownloadInProgress:(BOOL)downloadInProgress forUserID:(NSString *)userID
{
    userID = [self stringToUseForUserID:userID];

    @synchronized(self.currentlyDownloadingUserIDs)
    {
        if (downloadInProgress)
        {
            [self.currentlyDownloadingUserIDs addObject:userID];
        }
        else
        {
            [self.currentlyDownloadingUserIDs removeObject:userID];
        }
    }
}

#pragma mark - Properties

- (NSMutableDictionary *)configDictionary
{
    return self.configurationState.configurationDictionary;
}

- (void)setConfigDictionary:(NSMutableDictionary *)configDictionary
{
    self.configurationState.configurationDictionary = configDictionary;
}

- (BOOL)firstConfigDownloadFinished
{
    @synchronized(self)
    {
        return _firstConfigDownloadFinished;
    }
}

- (void)setFirstConfigDownloadFinished:(BOOL)firstConfigDownloadFinished
{
    @synchronized(self)
    {
        if (firstConfigDownloadFinished != _firstConfigDownloadFinished)
        {
            _firstConfigDownloadFinished = firstConfigDownloadFinished;
            [[NSUserDefaults standardUserDefaults] setBool:firstConfigDownloadFinished forKey:MSActiveConfigFirstDownloadFinishedUserDefaultsKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

@end