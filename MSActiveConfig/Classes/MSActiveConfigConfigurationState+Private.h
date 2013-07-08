//
//  MSActiveConfigConfigurationState+Private.h
//  MSActiveConfig
//
//  Created by Javier Soto on 7/8/13.
//  Copyright (c) 2013 MindSnacks. All rights reserved.
//

#import "MSActiveConfigConfigurationState.h"

@interface MSActiveConfigConfigurationState ()

/**
 Implementation detail. You should never have to access this dictionary directly.
 */
@property (nonatomic, readwrite, copy) NSDictionary *configurationDictionary;

@end