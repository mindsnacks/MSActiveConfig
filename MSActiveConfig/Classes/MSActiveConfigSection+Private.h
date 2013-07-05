//
//  MSActiveConfigSection+Private.h
//  MSActiveConfig
//
//  Created by Javier Soto on 6/27/12.
//  Copyright (c) 2012 MindSnacks. All rights reserved.
//

#import "MSActiveConfigSection.h"

@interface MSActiveConfigSection()

/**
 * @discussion these methods return nil if dictionary is not a valid dictionary or is nil.
 */
- (id)initWithDictionary:(NSDictionary *)dictionary;
+ (MSActiveConfigSection *)configSectionWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)settingsDictionary;

/**
 * @return an array containing the keys of all the config settings.
 */
- (NSArray *)configSettingKeys;

@end