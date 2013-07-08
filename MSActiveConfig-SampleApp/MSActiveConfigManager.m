//
//  MSActiveConfigManager.m
//  MSActiveConfig
//
//  Created by Javier Soto on 7/6/13.
//  Copyright (c) 2013 MindSnacks. All rights reserved.
//

#import "MSActiveConfigManager.h"

#import <MSActiveConfig/MSActiveConfig.h>
#import <MSActiveConfig/MSJSONURLRequestActiveConfigDownloader.h>
#import <MSActiveConfig/MSUserDefaultsActiveConfigStore.h>
#import <MSActiveConfig/MSActiveConfigConfigurationState.h>
#import <MSActiveConfig/MSActiveConfigConfigurationState+MSLazyLoadedState.h>

static MSActiveConfigManager *_activeConfigManager = nil;

@interface MSActiveConfigManager ()

@property (nonatomic, readwrite, strong) MSActiveConfig *activeConfig;

@end

@implementation MSActiveConfigManager

+ (void)initialize
{
    if (self == [MSActiveConfigManager class])
    {
        _activeConfigManager = [[self alloc] init];

        MSJSONURLRequestActiveConfigDownloader *downloader = [[MSJSONURLRequestActiveConfigDownloader alloc] initWithCreateRequestBlock:^NSURLRequest *(NSString *userID) {
            return [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://msactiveconfig-sampleapp.herokuapp.com/active_config?userID=%d", userID.intValue]]];
        }];

        MSUserDefaultsActiveConfigStore *store = [[MSUserDefaultsActiveConfigStore alloc] initWithInitialSharedConfiguration:[self initialActiveConfigState]];

        _activeConfigManager.activeConfig = [[MSActiveConfig alloc] initWithConfigDownloader:downloader
                                                                                 configStore:store];

        [_activeConfigManager.activeConfig downloadNewConfig];
    }
}

+ (instancetype)defaultInstance
{
    return _activeConfigManager;
}

+ (MSActiveConfigConfigurationState *)initialActiveConfigState
{
    NSString *bootstrappedActiveConfigFileName = @"InitialActiveConfig.json";
    NSString *bootstrappedActiveConfigFilePath = [[NSBundle mainBundle] pathForResource:bootstrappedActiveConfigFileName ofType:nil];

    return [MSActiveConfigConfigurationState lazyLoadedConfigurationStateFromJSONFileAtPath:bootstrappedActiveConfigFilePath];
}

@end
