//
//  MSActiveConfigStore.h
//  MSActiveConfig
//
//  Created by Javier Soto on 6/27/12.
//  Copyright (c) 2012 MindSnacks. All rights reserved.
//

@class MSActiveConfigConfigurationState;

@protocol MSActiveConfigStore <NSObject>

/**
 * @discussion return the last persisted configuration returned by the server and stored using -persistConfiguration:forUserID: or nil if non.
 * If initialSharedConfiguration was provided, and the store doesn't have any newest configuration, the shared configuration will be returned.
 */
- (MSActiveConfigConfigurationState *)lastKnownActiveConfigurationForUserID:(NSString *)userID;

/**
 * @discussion store the ConfigurationState in the provided user defaults with the provided userID and runlevel
 * @param configuration If nil, it removes the currently stored dictionary.
 * @param userID if nil, it stores it as the default, non user-specific configuration.
 */
- (void)persistConfiguration:(MSActiveConfigConfigurationState *)configuration forUserID:(NSString *)userID;

@end