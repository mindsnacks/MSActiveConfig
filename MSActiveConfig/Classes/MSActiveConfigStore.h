//
//  MSActiveConfigStore.h
//  MSActiveConfig
//
//  Created by Javier Soto on 6/27/12.
//  Copyright (c) 2012 MindSnacks. All rights reserved.
//

@class MSActiveConfigConfigurationState;


/**
 You can provide `MSActiveConfig` with an object that conforms to `MSActiveConfigStore` to allow it to retrieve the last known
 configuration when the app launches, and to store the subsequent updates that it downloads.
 */

@protocol MSActiveConfigStore <NSObject>

/**
 Return the last persisted configuration through `-persistConfiguration:forUserID:` or `nil`.
 @note There's no guarantee on which thread this method will be invoked on.
 */
- (MSActiveConfigConfigurationState *)lastKnownActiveConfigurationForUserID:(NSString *)userID;

/**
 The implementation of this method must persist the provided `MSActiveConfigConfigurationState` object synchronously.
 @param configuration If `nil`, it must removed the currently stored configuration for that `userID`.
 @param userID This method must store the configuration separately for each user. It can be `nil` for the *generic* configuration.
 @note `MSActiveConfigConfigurationState` conforms to `NSSecureCoding`.
 @note There's no guarantee on which thread this method will be invoked on.
 */
- (void)persistConfiguration:(MSActiveConfigConfigurationState *)configuration forUserID:(NSString *)userID;

@end