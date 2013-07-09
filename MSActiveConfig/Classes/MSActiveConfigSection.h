//
//  MSActiveConfigSection.h
//  MSActiveConfig
//
//  Created by Javier Soto on 6/27/12.
//  Copyright (c) 2012 MindSnacks. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 This objects represent a snapshot of configuration inside a section of the Configuration document.

 Refer to the Configuration Exchange Format documentation.
 
 ## Threading Notes
 `MSActiveConfigSection` objects are immutable, it's safe to keep them around and use them from different threads.
 
 ## MSActiveConfigSection and Type Safety
 These methods allow you to get a setting value from the `MSActiveConfigSection` by specifying the expected type.
 
 If the object present in the section for that key doesn't have that type, or there's no value for that key, these methods
 simply return nil.
 */

@interface MSActiveConfigSection : NSObject

///----------------------------
/// @name Querying for Values
///----------------------------

- (id)valueObjectForKey:(NSString *)key;

- (id)objectForKeyedSubscript:(NSString *)key;

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