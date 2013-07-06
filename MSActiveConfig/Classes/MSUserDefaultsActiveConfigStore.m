//
//  MSUserDefaultsActiveConfigStore.m
//  MSActiveConfig
//
//  Created by Javier Soto on 6/27/12.
//  Copyright (c) 2012 MindSnacks. All rights reserved.
//

#import "MSUserDefaultsActiveConfigStore.h"

#import "MSActiveConfigConfigurationState.h"

static NSString *const MSActiveConfigStoreUserDefaultsDefaultKey = @"MSActiveConfigStoreUserDefaults";

@interface MSUserDefaultsActiveConfigStore()

@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, strong) MSActiveConfigConfigurationState *initialSharedConfiguration;
@property (nonatomic, copy) MSUserDefaultsActiveConfigStoreCreateKeyBlock createKeyBlock;

@end

@implementation MSUserDefaultsActiveConfigStore

- (id)init
{
    return [self initWithInitialSharedConfiguration:nil];
}

- (id)initWithInitialSharedConfiguration:(MSActiveConfigConfigurationState *)initialSharedConfiguration
{
    return [self initWithUserDefaults:[NSUserDefaults standardUserDefaults]
           initialSharedConfiguration:initialSharedConfiguration];
}

- (id)initWithUserDefaults:(NSUserDefaults *)userDefaults
initialSharedConfiguration:(MSActiveConfigConfigurationState *)initialSharedConfiguration
{
return [self initWithUserDefaults:userDefaults
       initialSharedConfiguration:initialSharedConfiguration
                   createKeyBlock:^NSString *(NSString *userID)
    {
        return [NSString stringWithFormat:@"%@_%@", MSActiveConfigStoreUserDefaultsDefaultKey, userID];
    }];
}

- (id)initWithUserDefaults:(NSUserDefaults *)userDefaults
initialSharedConfiguration:(MSActiveConfigConfigurationState *)initialSharedConfiguration
            createKeyBlock:(MSUserDefaultsActiveConfigStoreCreateKeyBlock)createKeyBlock
{
    NSParameterAssert(userDefaults);
    NSParameterAssert(createKeyBlock);

    if ((self = [super init]))
    {
        self.userDefaults = userDefaults;
        self.initialSharedConfiguration = initialSharedConfiguration;
        self.createKeyBlock = createKeyBlock;
    }

    return self;
}

#pragma mark -

- (NSString *)userDefaultsKeyForCurrentUserID:(NSString *)userID
{
    NSString *userDefaultsKey = self.createKeyBlock(userID);

    NSParameterAssert(userDefaultsKey);

    return userDefaultsKey;
}

#pragma mark - MSActiveConfigStore Protocol

- (MSActiveConfigConfigurationState *)lastKnownActiveConfigurationForUserID:(NSString *)userID
{
    NSData *archivedData = [self.userDefaults objectForKey:[self userDefaultsKeyForCurrentUserID:userID]];

    if ([archivedData isKindOfClass:[NSData class]])
    {
        // 1. If the user has stored configuration
        MSActiveConfigConfigurationState *configurationState = nil;

        @try
        {
            configurationState = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
        }
        @catch (NSException *exception)
        {
            NSLog(@"Error reading persisted %@ object: \"%@\"", NSStringFromClass([MSActiveConfigConfigurationState class]), exception);
        }
        @finally
        {
            if ([configurationState isKindOfClass:[MSActiveConfigConfigurationState class]])
            {
                return configurationState;
            }
        }
    }

    if (userID)
    {
        // 2. If it doesn't, fallback to the "null user" general configuration.
        return [self lastKnownActiveConfigurationForUserID:nil];
    }
    else
    {
        // If there's no configuration for the "null user", fall back to the bootstrapped config.
        return self.initialSharedConfiguration;
    }
}

- (void)persistConfiguration:(MSActiveConfigConfigurationState *)configuration forUserID:(NSString *)userID
{
    NSString *userDefaultsKey = [self userDefaultsKeyForCurrentUserID:userID];

    if (configuration)
    {
        [self.userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:configuration] forKey:userDefaultsKey];

        if (!userID)
        {
            // No need to keep this around anymore, we have a more recent version to fall back to.
            self.initialSharedConfiguration = nil;
        }
    }
    else
    {
        [self.userDefaults removeObjectForKey:userDefaultsKey];
    }

    [self.userDefaults synchronize];
}

@end
