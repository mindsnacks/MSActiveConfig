//
//  MSActiveConfigSection.h
//  MSActiveConfig
//
//  Created by Javier Soto on 6/27/12.
//  Copyright (c) 2012 MindSnacks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSActiveConfigSection : NSObject

- (id)valueObjectForKey:(NSString *)key;

- (NSString *)stringForKey:(NSString *)key;

- (NSArray *)arrayForKey:(NSString *)key;

- (NSArray *)stringArrayForKey:(NSString *)key;

- (NSDictionary *)dictionaryForKey:(NSString *)key;

- (NSURL *)URLForKey:(NSString *)key;

- (NSInteger)integerForKey:(NSString *)key;

- (float)floatForKey:(NSString *)key;

- (double)doubleForKey:(NSString *)key;

- (BOOL)boolForKey:(NSString *)key;

@end