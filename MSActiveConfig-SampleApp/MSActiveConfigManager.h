//
//  MSActiveConfigManager.h
//  MSActiveConfig
//
//  Created by Javier Soto on 7/6/13.
//  Copyright (c) 2013 MindSnacks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MSActiveConfig;

@interface MSActiveConfigManager : NSObject

+ (instancetype)defaultInstance;

@property (nonatomic, readonly, strong) MSActiveConfig *activeConfig;

@end
