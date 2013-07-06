//
//  MSActiveConfigSection.m
//  MSActiveConfig
//
//  Created by Javier Soto on 6/27/12.
//  Copyright (c) 2012 MindSnacks. All rights reserved.
//

#import "MSActiveConfigSection.h"
#import "MSActiveConfigSection+Private.h"

static NSString *const MSActiveConfigSectionSettingsKey = @"settings";
static NSString *const MSActiveConfigSectionValueKey = @"value";

@interface MSActiveConfigSection()

@property (nonatomic, readonly, copy) NSDictionary *configDictionary;

@end

@implementation MSActiveConfigSection

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if ((self = [super init]))
    {
        if ([dictionary isKindOfClass:[NSDictionary class]])
        {
            _configDictionary = [dictionary copy];
        }
        else
        {
            self = nil;
        }
    }
    
    return self;
}

- (id)init
{
    return [self initWithDictionary:nil];
}

+ (MSActiveConfigSection *)configSectionWithDictionary:(NSDictionary *)dictionary
{
    return [[self alloc] initWithDictionary:dictionary];
}

#pragma mark - 

- (BOOL)isEqual:(id)object
{
    if (object == self)
    {
        return YES;
    }

    if (![object isKindOfClass:[MSActiveConfigSection class]])
    {
        return NO;
    }
    
    MSActiveConfigSection *otherConfigSection = object;
    
    return [self.configDictionary isEqualToDictionary:otherConfigSection.configDictionary];
}

- (NSUInteger)hash
{
    return [self.configDictionary hash];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p>: %@", NSStringFromClass(self.class), self, self.configDictionary];
}

#pragma mark - Private Methods

- (NSDictionary *)settingsDictionary
{
    return [self.configDictionary objectForKey:MSActiveConfigSectionSettingsKey];
}

- (NSArray *)configSettingKeys
{
    return self.settingsDictionary.allKeys;
}

- (id)valueObjectForKey:(NSString *)key expectedClass:(Class)expectedClass
{
    id object = [self valueObjectForKey:key];
    
    return ([object isKindOfClass:expectedClass]) ? object : nil;
}

- (id)valueObjectForKey:(NSString *)key ifImplementsSelector:(SEL)selector
{
    id object = [self valueObjectForKey:key];

    return ([object respondsToSelector:selector]) ? object : nil;
}

#pragma mark - Public Methods

- (id)valueObjectForKey:(NSString *)key
{
    NSDictionary *settingsDictionary = [self settingsDictionary];
    
    if ([settingsDictionary isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *objectForThatKey = [settingsDictionary objectForKey:key];
        
        if ([objectForThatKey isKindOfClass:[NSDictionary class]])
        {
            return [objectForThatKey objectForKey:MSActiveConfigSectionValueKey];
        }
    }

    return nil;
}

- (NSString *)stringForKey:(NSString *)key
{
    return [self valueObjectForKey:key expectedClass:[NSString class]];
}

- (NSArray *)arrayForKey:(NSString *)key
{
    return [self valueObjectForKey:key expectedClass:[NSArray class]];
}

- (NSArray *)stringArrayForKey:(NSString *)key
{
    NSArray *array = [self arrayForKey:key];
    
    for (id object in array)
    {
        if (![object isKindOfClass:[NSString class]])
        {
            return nil;
        }
    }
    
    return array;            
}

- (NSDictionary *)dictionaryForKey:(NSString *)key
{
    return [self valueObjectForKey:key expectedClass:[NSDictionary class]];    
}

- (NSURL *)URLForKey:(NSString *)key
{
    NSURL *url = [self valueObjectForKey:key expectedClass:[NSURL class]];
    
    if (!url)
    {
        NSString *stringValue = [self stringForKey:key];
        
        url = [NSURL URLWithString:[stringValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return url;
}

- (NSInteger)integerForKey:(NSString *)key
{
    id numberObject = [self valueObjectForKey:key ifImplementsSelector:@selector(intValue)];
    
    return [numberObject intValue];
}

- (float)floatForKey:(NSString *)key
{
    id floatObject = [self valueObjectForKey:key ifImplementsSelector:@selector(floatValue)];
    
    return [floatObject floatValue];
}

- (double)doubleForKey:(NSString *)key
{
    id doubleObject = [self valueObjectForKey:key ifImplementsSelector:@selector(doubleValue)];
    
    return [doubleObject doubleValue];
}

- (BOOL)boolForKey:(NSString *)key
{
    id boolObject = [self valueObjectForKey:key ifImplementsSelector:@selector(boolValue)];
    
    return [boolObject boolValue];
}

@end