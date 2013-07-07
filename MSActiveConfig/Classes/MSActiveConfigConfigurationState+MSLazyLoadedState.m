//
//  MSActiveConfigConfigurationState+MSLazyLoadedState.m
//  MSActiveConfig
//
//  Created by Javier Soto on 7/7/13.
//  Copyright (c) 2013 MindSnacks. All rights reserved.
//

#import "MSActiveConfigConfigurationState+MSLazyLoadedState.h"

typedef MSActiveConfigConfigurationState *(^_MSActiveConfigConfigurationStateFutureConfigStateLoadBlock)(void);

/**
 * @discussion pretends to be a `MSActiveConfigConfigurationState`, but doesn't load the dictionary until a config section
 * is queried. This delays the load of the JSON from disk until it's really necessary.
 * In many cases, this load might not even happen.
 */
@interface _MSActiveConfigConfigurationStateFuture : MSActiveConfigConfigurationState

+ (_MSActiveConfigConfigurationStateFuture *)configStateFutureWithLoadBlock:(_MSActiveConfigConfigurationStateFutureConfigStateLoadBlock)loadBlock;

@end

@implementation MSActiveConfigConfigurationState (MSLazyLoadedState)

+ (MSActiveConfigConfigurationState *)lazyLoadedConfigurationStateFromJSONFileAtPath:(NSString *)JSONFilePath
{
    _MSActiveConfigConfigurationStateFuture *configState = [_MSActiveConfigConfigurationStateFuture configStateFutureWithLoadBlock:^MSActiveConfigConfigurationState *{
        NSError *fileLoadError = nil;
        NSData *initialConfig = [[NSData alloc] initWithContentsOfFile:JSONFilePath
                                                               options:0
                                                                 error:&fileLoadError];
        NSAssert(!fileLoadError, @"Can't load Initial Config from file at path %@ (Error: %@)", JSONFilePath, fileLoadError);

        NSError *JSONParseError = nil;
        NSDictionary *initialConfigDictionary = [NSJSONSerialization JSONObjectWithData:initialConfig
                                                                                options:0
                                                                                  error:&JSONParseError];
        NSAssert(!JSONParseError, @"Error parsing JSON at path %@: %@", JSONFilePath, JSONParseError);

        MSActiveConfigConfigurationState *configurationState = [[MSActiveConfigConfigurationState alloc] initWithDictionary:initialConfigDictionary];
        NSAssert(configurationState.configurationDictionary.count > 0, @"Couldn't create %@ object from JSON file at path %@", NSStringFromClass([MSActiveConfigConfigurationState class]), JSONFilePath);

        return configurationState;
    }];

    return configState;
}

@end

@interface _MSActiveConfigConfigurationStateFuture ()

@property (nonatomic, strong) NSCache *memoryCache;

@property (nonatomic, copy) _MSActiveConfigConfigurationStateFutureConfigStateLoadBlock configStateLoadBlock;

@end

@implementation _MSActiveConfigConfigurationStateFuture

+ (_MSActiveConfigConfigurationStateFuture *)configStateFutureWithLoadBlock:(_MSActiveConfigConfigurationStateFutureConfigStateLoadBlock)loadBlock
{
    NSParameterAssert(loadBlock);

    _MSActiveConfigConfigurationStateFuture *future = [[self alloc] init];
    future.configStateLoadBlock = loadBlock;

    return future;
}

- (id)init
{
    if ((self = [super init]))
    {
        self.memoryCache = [[NSCache alloc] init];
        self.memoryCache.name = NSStringFromClass([self class]);
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [self.actualConfigState encodeWithCoder:aCoder];
}

- (MSActiveConfigSection *)configSectionWithName:(NSString *)configKey
{
    return [self.actualConfigState configSectionWithName:configKey];
}

- (NSArray *)configSectionNames
{
    return [self.actualConfigState configSectionNames];
}

- (NSDictionary *)meta
{
    return self.actualConfigState.meta;
}

- (NSDictionary *)configurationDictionary
{
    return [self.actualConfigState configurationDictionary];
}

- (NSString *)creationDateString
{
    return self.actualConfigState.creationDateString;
}

- (NSString *)formatVersion
{
    return self.actualConfigState.formatVersion;
}

- (MSActiveConfigConfigurationState *)actualConfigState
{
    MSActiveConfigConfigurationState *configState = nil;

    @synchronized(self)
    {
        static NSString *const MSActiveConfigConfigurationStateFutureCacheKey = @"com.mindsnacks.activeconfig.configurationstatefuture";

        configState = [self.memoryCache objectForKey:MSActiveConfigConfigurationStateFutureCacheKey];

        if (!configState)
        {
            configState = self.configStateLoadBlock();

            [self.memoryCache setObject:configState forKey:MSActiveConfigConfigurationStateFutureCacheKey];
        }
    }
    
    return configState;
}

@end