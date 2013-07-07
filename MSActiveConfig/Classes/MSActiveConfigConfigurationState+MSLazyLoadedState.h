//
//  MSActiveConfigConfigurationState+MSLazyLoadedState.h
//  MSActiveConfig
//
//  Created by Javier Soto on 7/7/13.
//  Copyright (c) 2013 MindSnacks. All rights reserved.
//

#import "MSActiveConfigConfigurationState.h"

@interface MSActiveConfigConfigurationState (MSLazyLoadedState)

/**
 * @return a `MSActiveConfigConfigurationState` object that you can use to initialize a `MSUserDefaultsActiveConfigStore`
 * which doesn't load and parses the contents of the specified file unless it's asked to.
 * This prevents loading the initial configuration from disk if active config already knows of a newer configuration,
 * (essentially only loading the contents of the file on the first app launch).
 * @throws if it can't create a configuration state from the file at the provided path.
 */
+ (MSActiveConfigConfigurationState *)lazyLoadedConfigurationStateFromJSONFileAtPath:(NSString *)JSONFilePath;

@end