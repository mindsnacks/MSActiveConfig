//
//  MSActiveConfig+Private.h
//  MSActiveConfig
//
//  Created by Javier Soto on 6/27/12.
//  Copyright (c) 2012 MindSnacks. All rights reserved.
//

#import "MSActiveConfig.h"

@class MSActiveConfigConfigurationState, MSActiveConfigMutableConfigurationState;

/**
 * @discussion private extension of MSActiveConfig
 * @warning These methods are not thread safe and should not be used for anything other than testing.
 */
@interface MSActiveConfig()

@property (nonatomic, readonly, strong) NSMutableDictionary *configDictionary;
@property (nonatomic, readonly, strong) MSActiveConfigMutableConfigurationState *configurationState;

/**
 * @discussion defaults to dispatch_get_main_queue().
 * @note this can be used in tests to have notifications be delivered on a background thread and avoid deadlocks while waiting for them.
 */
@property (nonatomic, strong) dispatch_queue_t listenerNotificationsQueue;

/**
 * @discussion this happens synchronously to the caller.
 * Listeners will only be notified if userID is the same as -[MSActiveConfig currentUserID].    
 */
- (void)setNewConfigState:(MSActiveConfigConfigurationState *)newConfigurationState forUserID:(NSNumber *)userID;

@end