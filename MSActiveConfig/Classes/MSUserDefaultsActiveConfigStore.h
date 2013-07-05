//
//  MSUserDefaultsActiveConfigStore.h
//  MSActiveConfig
//
//  Created by Javier Soto on 7/5/13.
//  Copyright (c) 2013 MindSnacks. All rights reserved.
//

#import "MSActiveConfigStore.h"

@interface MSUserDefaultsActiveConfigStore : NSObject <MSActiveConfigStore>

- (id)initWithUserDefaults:(NSUserDefaults *)userDefaults
initialSharedConfiguration:(MSActiveConfigConfigurationState *)initialSharedConfiguration;

@end
