//
//  MSUserDefaultsActiveConfigStore.h
//  MSActiveConfig
//
//  Created by Javier Soto on 7/5/13.
//  Copyright (c) 2013 MindSnacks. All rights reserved.
//

#import "MSActiveConfigStore.h"

typedef NSString *(^MSUserDefaultsActiveConfigStoreCreateKeyBlock)(NSString *userID);

@interface MSUserDefaultsActiveConfigStore : NSObject <MSActiveConfigStore>

/**
 * @param initialSharedConfiguration: configuration state used for every user until a newer configuration is retrieved.
 */
- (id)initWithInitialSharedConfiguration:(MSActiveConfigConfigurationState *)initialSharedConfiguration;

/**
 * @param userDefaults: default +[NSUserDefaults standardUserDefaults] if you use the simpler initializer.
 */
- (id)initWithUserDefaults:(NSUserDefaults *)userDefaults
initialSharedConfiguration:(MSActiveConfigConfigurationState *)initialSharedConfiguration;

/**
 * @param createKeyBlock: optionally use this initializer to provide a custom NSUserDefaults key. 
 * The block may be called from an arbitrary thread. Must return non nil.
 */
- (id)initWithUserDefaults:(NSUserDefaults *)userDefaults
initialSharedConfiguration:(MSActiveConfigConfigurationState *)initialSharedConfiguration
            createKeyBlock:(MSUserDefaultsActiveConfigStoreCreateKeyBlock)createKeyBlock;

@end
