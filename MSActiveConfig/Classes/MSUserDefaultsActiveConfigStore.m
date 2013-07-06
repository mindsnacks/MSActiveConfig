//
//  MSUserDefaultsActiveConfigStore.m
//  MSActiveConfig
//
//  Created by Javier Soto on 6/27/12.
//  Copyright (c) 2012 MindSnacks. All rights reserved.
//

#import "MSUserDefaultsActiveConfigStore.h"

#import "MSActiveConfigConfigurationState.h"

static NSString *const MSActiveConfigStoreUserDefaultsKey = @"MSActiveConfigStoreUserDefaults";

@interface MSUserDefaultsActiveConfigStore()

@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, strong) MSActiveConfigConfigurationState *initialSharedConfiguration;

@end

@implementation MSUserDefaultsActiveConfigStore

- (id)initWithUserDefaults:(NSUserDefaults *)userDefaults
initialSharedConfiguration:(MSActiveConfigConfigurationState *)initialSharedConfiguration
{
    NSParameterAssert(userDefaults);

    if ((self = [super init]))
    {
        self.userDefaults = userDefaults;
        self.initialSharedConfiguration = initialSharedConfiguration;
    }

    return self;
}

- (id)init
{
    return [self initWithUserDefaults:nil
           initialSharedConfiguration:nil];
}

#pragma mark -

- (NSString *)userDefaultsKeyForCurrentRunLevelAndUserID:(NSString *)userID
{
    const NSInteger legacyNumericValue = 2;

    return [NSString stringWithFormat:@"%@_%d_%@", MSActiveConfigStoreUserDefaultsKey, legacyNumericValue, userID];
}

#pragma mark - MSActiveConfigStore Protocol

- (MSActiveConfigConfigurationState *)lastKnownActiveConfigurationForUserID:(NSString *)userID
{
    NSData *archivedData = [self.userDefaults objectForKey:[self userDefaultsKeyForCurrentRunLevelAndUserID:userID]];

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
    NSString *userDefaultsKey = [self userDefaultsKeyForCurrentRunLevelAndUserID:userID];

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
