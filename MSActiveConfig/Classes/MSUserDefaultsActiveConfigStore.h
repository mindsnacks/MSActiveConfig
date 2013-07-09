//
//  MSUserDefaultsActiveConfigStore.h
//  MSActiveConfig
//
//  Created by Javier Soto on 7/5/13.
//  Copyright (c) 2013 MindSnacks. All rights reserved.
//

#import "MSActiveConfigStore.h"

typedef NSString *(^MSUserDefaultsActiveConfigStoreCreateKeyBlock)(NSString *userID);

/**
 This is a concrete implementation of the `MSActiveConfigStore` protocol that uses `NSUserDefaults` as its backing store.

 Using this class is encouraged for most applications. It uses `NSKeyedArchiver` to persist the configuration state
 objects, but this shouldn't be a performance issue because `MSActiveConfig` does all its work on a background queue.
 
 `MSUserDefaultsActiveConfigStore` also allows you to specify a fallback `MSActiveConfigConfigurationState` object that
 `MSActiveConfig` will be able to use until it can download a newer configuration. This lets you ship your application
 with a base, default configuration.
 */

// Say something about: " If `initialSharedConfiguration` was provided, and the store doesn't have any newest configuration, the shared configuration will be returned."
@interface MSUserDefaultsActiveConfigStore : NSObject <MSActiveConfigStore>

///----------------------------
/// @name Initialization
///----------------------------

/**
 Simpler `-init` method, this method is good enough for most applications.
 It uses `+[NSUserDefaults standardUserDefaults]` and a reasonable, namespaced user defaults key.
 @param initialSharedConfiguration Configuration state used for every user until a newer configuration is retrieved.
 */
- (id)initWithInitialSharedConfiguration:(MSActiveConfigConfigurationState *)initialSharedConfiguration;

/**
 You can use this method to mock `NSUserDefaults`.
 @param initialSharedConfiguration Configuration state used for every user until a newer configuration is retrieved.
 */
- (id)initWithUserDefaults:(NSUserDefaults *)userDefaults
initialSharedConfiguration:(MSActiveConfigConfigurationState *)initialSharedConfiguration;

/**
 This is the designated initializer. All other methods call here with default values.
 @param createKeyBlock Optionally use this initializer to provide a custom `NSUserDefaults` key. 
 It takes a `userID` string and must return a string used as key in `NSUserDefaults.` Must be different for every userID.
 The block may be called from an arbitrary thread. Must return non nil.
 */
- (id)initWithUserDefaults:(NSUserDefaults *)userDefaults
initialSharedConfiguration:(MSActiveConfigConfigurationState *)initialSharedConfiguration
            createKeyBlock:(MSUserDefaultsActiveConfigStoreCreateKeyBlock)createKeyBlock;

@end
