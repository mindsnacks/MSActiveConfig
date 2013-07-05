//
//  MSActiveConfig_Test.m
//  MSAppKit
//
//  Created by Javier Soto on 6/26/12.
//  Copyright (c) 2012 MindSnacks. All rights reserved.
//

#import "MSActiveConfig_BaseTest.h"

#import <MSActiveConfig/MSActiveConfig.h>
#import "MSActiveConfig+Private.h"

#import "MSActiveConfigSection.h"
#import "MSActiveConfigSection+Private.h"

#import "MSActiveConfigConfigurationState.h"
#import "MSActiveConfigMutableConfigurationState.h"

#import "MSActiveConfigStore.h"

#import "MSActiveConfigDownloader.h"

static NSString *const kSectionName =  @"SectionName";

#define WaitForAsyncOperations() [NSThread sleepForTimeInterval:0.05f]
#define WaitForNotificationsToBeDelivered() WaitForAsyncOperations()
#define WaitForLastKnownConfigurationToBeLoaded() WaitForAsyncOperations()

@interface MSActiveConfig_Test : MSActiveConfig_BaseTest
{
    MSActiveConfig *_activeConfig;
}
@end

@implementation MSActiveConfig_Test

- (void)setUp
{
    [super setUp];

    _activeConfig = [[MSActiveConfig alloc] initWithConfigDownloader:[self fakeConfigDownloader] configStore:nil];
    _activeConfig.listenerNotificationsQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

- (void)tearDown
{
    _activeConfig = nil;

    MSClearAllNSUserDefaults();

    [super tearDown];
}

#pragma mark - Utils

- (id)fakeConfigDownloader
{
    id configDownloader = [OCMockObject niceMockForProtocol:@protocol(MSActiveConfigDownloader)];
    [[[configDownloader stub] andReturn:nil] requestActiveConfigForUserWithID:OCMOCK_ANY error:(NSError *__autoreleasing *)[OCMArg anyPointer]];

    return configDownloader;
}

- (id)activeConfigStoreWithStoredState:(MSActiveConfigMutableConfigurationState *)state
{
    id configStore = [OCMockObject mockForProtocol:@protocol(MSActiveConfigStore)];
    [[[configStore expect] andReturn:state] lastKnownActiveConfigurationForUserID:nil];

    [[configStore stub] persistConfiguration:[OCMArg any] forUserID:nil];

    return configStore;
}

- (MSActiveConfig *)activeConfigWithFakeDownloaderAndStoredState:(MSActiveConfigMutableConfigurationState *)state
{
    id store = [self activeConfigStoreWithStoredState:state];
    MSActiveConfig *activeConfig = [[MSActiveConfig alloc] initWithConfigDownloader:[self fakeConfigDownloader] configStore:store];
    activeConfig.listenerNotificationsQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    return activeConfig;
}

- (id)listenerMock
{
    id listener = [OCMockObject mockForProtocol:@protocol(MSActiveConfigListener)];

    return listener;
}

- (NSDictionary *)sampleDownloadedSettings
{
    return (@{
            @"meta" : (@{
                       @"format_version_string" : @"1.0",
                       @"creation_time" : @"2012-08-13T19:36Z",
                       }),
            @"config_sections" : (@{
                                  @"ConfigKey" : (@{
                                                  @"settings" : (@{
                                                                 @"SomeConfig" : (@{
                                                                                  @"value" :
                                                                                  @"SomeValue"
                                                                                  })
                                                                 })
                                                  })
                                  })
            });
}

- (void)expectConfigDownloadInActiveConfig:(MSActiveConfig *)activeConfig
                                    userID:(NSString *)userID
{
    NSDictionary *downloadedSettings = [self sampleDownloadedSettings];

    id downloader = activeConfig.configDownloader;

    [[[downloader expect] andReturn:downloadedSettings] requestActiveConfigForUserWithID:userID error:(NSError *__autoreleasing *)[OCMArg anyPointer]];

    [activeConfig downloadNewConfig];

    __block BOOL settingsWhereSet = NO;

    double timeout = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        STAssertEqualObjects(activeConfig.configDictionary, [downloadedSettings valueForKey:@"config_sections"], @"Should set the downloaded settings");
        settingsWhereSet = YES;
    });

    MSTestWaitUntilTrue(settingsWhereSet);

    [downloader verify];
}

- (void)assertBlock:(dispatch_block_t)block throws:(BOOL)throws withDescription:(NSString *)description
{
    if (throws)
    {
        STAssertThrows(block(), description);
    }
    else
    {
        STAssertNoThrow(block(), description);
    }
}

#pragma mark - Tests

- (void)testThatActiveConfigCanBeInstantiatedWithoutStore
{
    [self assertBlock:^{__unused id ac = [[MSActiveConfig alloc] initWithConfigDownloader:[self fakeConfigDownloader] configStore:nil];}
               throws:NO
      withDescription:@"Active config should allow to be instantiated without store"];
}

- (void)testThatActiveConfigCanNotBeInstantiatedWithoutDownloader
{
    [self assertBlock:^{__unused id ac = [[MSActiveConfig alloc] initWithConfigDownloader:nil configStore:[self activeConfigStoreWithStoredState:nil]];}
               throws:YES
      withDescription:@"Active config should allow to be instantiated without downloader"];
}

- (void)testThatYouCantRegisterANilListener
{
    STAssertThrows([_activeConfig registerListener:nil forSectionName:@"SomeKey"], @"You shouldn't be able to register a nil listener");
}

- (void)testThatYouCantRegisterWithANilKey
{
    STAssertThrows([_activeConfig registerListener:(id)self forSectionName:nil], @"You shouldn't be able to register with a nil key");
}

- (void)testThatYouCantUnregisterANilClient
{
    STAssertThrows([_activeConfig removeListener:nil forSectionName:@"SomeKey"], @"You shouldn't be able to unregister a nil listener");
}

- (void)testThatYouCantUnregisterWithANilKey
{
    STAssertThrows([_activeConfig removeListener:(id)self forSectionName:nil], @"You shouldn't be able to unregister with a nil key");
}

- (void)testThatSettingANewConfigTriggersNotifyingTheClients
{
    NSDictionary *settingsForListener = @{
                                          @"SomeConfig" : @{
                                                  @"value" : @"SomeValue"
                                                  }
                                          };

    NSDictionary *configDictionary = @{ kSectionName : settingsForListener };

    MSActiveConfigMutableConfigurationState *configState = [self configStateWithConfigDictionary:configDictionary];

    MSActiveConfigSection *configSection = [MSActiveConfigSection configSectionWithDictionary:settingsForListener];

    id listener = [self listenerMock];

    [_activeConfig registerListener:listener forSectionName:kSectionName];

    [[listener expect] activeConfig:_activeConfig didReceiveConfigSection:configSection forSectionName:kSectionName];

    [_activeConfig setNewConfigState:configState forUserID:nil];

    WaitForNotificationsToBeDelivered();

    [_activeConfig removeListener:listener forSectionName:kSectionName];

    [listener verify];
}

- (void)testThatRemovingAListenerMakesItNotReceiveAConfigChange
{
    NSDictionary *settingsForListener = @{
                                          @"SomeConfig" : @{
                                                  @"value" : @"SomeValue"
                                                  }
                                          };

    NSDictionary *configDictionary = @{ kSectionName : settingsForListener };

    MSActiveConfigMutableConfigurationState *configState = [self configStateWithConfigDictionary:configDictionary];

    MSActiveConfigSection *configSection = [MSActiveConfigSection configSectionWithDictionary:settingsForListener];

    id listener = [self listenerMock];

    [_activeConfig registerListener:listener forSectionName:kSectionName];
    [_activeConfig removeListener:listener forSectionName:kSectionName];

    [[listener reject] activeConfig:_activeConfig didReceiveConfigSection:configSection forSectionName:kSectionName];

    [_activeConfig setNewConfigState:configState forUserID:nil];

    WaitForNotificationsToBeDelivered();

    [listener verify];
}

- (void)testTheListenersAreNotNotifiedIfActiveConfigGetsTheSameConfig
{
    NSDictionary *settingsForListener = @{
                                          @"SomeConfig" : @{
                                                  @"value" : @"SomeValue"
                                                  }
                                          };

    NSDictionary *configDictionary = @{ kSectionName : settingsForListener };

    MSActiveConfigMutableConfigurationState *configState = [self configStateWithConfigDictionary:configDictionary];

    MSActiveConfigSection *configSection = [MSActiveConfigSection configSectionWithDictionary:settingsForListener];

    id listener = [self listenerMock];

    [_activeConfig registerListener:listener forSectionName:kSectionName];
    WaitForNotificationsToBeDelivered();

    [[listener expect] activeConfig:_activeConfig didReceiveConfigSection:configSection forSectionName:kSectionName];

    [_activeConfig setNewConfigState:configState forUserID:nil];

    WaitForNotificationsToBeDelivered();

    [[listener reject] activeConfig:_activeConfig didReceiveConfigSection:configSection forSectionName:kSectionName];

    // set the same settings again. This shouldn't trigger an update.
    [_activeConfig setNewConfigState:configState forUserID:nil];

    WaitForNotificationsToBeDelivered();

    [listener verify];

    [_activeConfig removeListener:listener forSectionName:kSectionName];
}

#pragma mark - Store persitation

- (void)testThatActiveConfigReadsFromStoreIfItsProvidedWithOne
{
    NSDictionary *settingsForListener = @{
                                          @"SomeConfig" : @{
                                                  @"value" : @"SomeValue"
                                                  }
                                          };

    NSDictionary *configDictionary = @{ kSectionName : settingsForListener };

    MSActiveConfigMutableConfigurationState *configState = [self configStateWithConfigDictionary:configDictionary];

    MSActiveConfig *activeConfig = [self activeConfigWithFakeDownloaderAndStoredState:configState];

    WaitForLastKnownConfigurationToBeLoaded();

    STAssertEqualObjects(configDictionary, activeConfig.configDictionary, @"Should use the provided persisted info from the store");
}

- (void)testThatYouGetTheInitialSettingsOnRegistering
{
    NSDictionary *settingsForListener = @{
                                          @"SomeConfig" : @{
                                                  @"value" : @"SomeValue"
                                                  }
                                          };

    NSDictionary *configDictionary = @{ kSectionName : settingsForListener };

    MSActiveConfigMutableConfigurationState *configState = [self configStateWithConfigDictionary:configDictionary];

    MSActiveConfigSection *configSection = [MSActiveConfigSection configSectionWithDictionary:settingsForListener];

    MSActiveConfig *activeConfig = [self activeConfigWithFakeDownloaderAndStoredState:configState];

    WaitForLastKnownConfigurationToBeLoaded();

    id listener = [self listenerMock];

    [[listener expect] activeConfig:activeConfig didReceiveConfigSection:configSection forSectionName:kSectionName];

    [activeConfig registerListener:listener forSectionName:kSectionName];

    WaitForNotificationsToBeDelivered();

    [listener verify];

    [activeConfig removeListener:listener forSectionName:kSectionName];
}

- (void)testThatAListenerDoesntGetAnySettingIfTheresNothingPersistedForTheKeyThatItListensTo
{
    NSDictionary *settingsForListener = @{
                                          @"ConfigKey" : @{
                                                  @"value" : @"SomeValue"
                                                  }
                                          };

    NSDictionary *configDictionary = @{ @"SomeKey" : settingsForListener };

    MSActiveConfigMutableConfigurationState *configState = [self configStateWithConfigDictionary:configDictionary];

    MSActiveConfigSection *configSection = [MSActiveConfigSection configSectionWithDictionary:settingsForListener];

    MSActiveConfig *activeConfig = [self activeConfigWithFakeDownloaderAndStoredState:configState];
    WaitForLastKnownConfigurationToBeLoaded();

    id listener = [self listenerMock];

    [[listener reject] activeConfig:activeConfig didReceiveConfigSection:configSection forSectionName:kSectionName];

    [activeConfig registerListener:listener forSectionName:kSectionName];

    WaitForNotificationsToBeDelivered();

    [listener verify];

    [activeConfig removeListener:listener forSectionName:kSectionName];
}

- (void)testAListenerIsNotNotifiedIfTheConfigForItsKeyHasNotChanged
{
    NSString *otherKey = @"SomeOtherKey";

    NSDictionary *allSettings = @{
                                  otherKey : @{
                                          @"SomeSettingKey" : @"SomeValue"
                                          },
                                  kSectionName : @{
                                          @"SomeSettingKey" : @"SomeOtherValue"
                                          }
                                  };

    MSActiveConfigSection *configSection = [MSActiveConfigSection configSectionWithDictionary:[allSettings valueForKey:kSectionName]];

    id listener = [self listenerMock];

    MSActiveConfigMutableConfigurationState *configState = [self configStateWithConfigDictionary:allSettings];
    MSActiveConfig *activeConfig = [self activeConfigWithFakeDownloaderAndStoredState:configState];

    WaitForLastKnownConfigurationToBeLoaded();

    [[listener expect] activeConfig:activeConfig didReceiveConfigSection:configSection forSectionName:kSectionName];

    [activeConfig registerListener:listener forSectionName:kSectionName];

    WaitForNotificationsToBeDelivered();

    [[listener reject] activeConfig:activeConfig didReceiveConfigSection:configSection forSectionName:kSectionName];

    NSMutableDictionary *newSettings = [allSettings mutableCopy];
    [newSettings setValue:[NSDictionary dictionaryWithObject:@"ChangedValue" forKey:@"SomeSettingKey"] forKey:otherKey];

    MSActiveConfigMutableConfigurationState *newConfigState = [self configStateWithConfigDictionary:newSettings];

    [activeConfig setNewConfigState:newConfigState forUserID:nil];

    WaitForNotificationsToBeDelivered();

    [listener verify];

    [activeConfig removeListener:listener forSectionName:kSectionName];
}

- (void)testThatAListenerDoesntGetInitialSettingsIfThereIsNothingForItsKey
{
    NSDictionary *settingsForListener = @{
                                          @"SomeConfig" : @{
                                                  @"value" : @"SomeValue"
                                                  }
                                          };

    NSDictionary *configDictionary = @{ @"SomeOtherKey" : settingsForListener };

    MSActiveConfigMutableConfigurationState *configState = [self configStateWithConfigDictionary:configDictionary];

    id listener = [self listenerMock];

    [_activeConfig setNewConfigState:configState forUserID:nil];

    [[listener reject] activeConfig:_activeConfig didReceiveConfigSection:[OCMArg any] forSectionName:[OCMArg any]];

    [_activeConfig registerListener:listener forSectionName:kSectionName];

    WaitForNotificationsToBeDelivered();

    [listener verify];

    [_activeConfig removeListener:listener forSectionName:kSectionName];
}

- (void)testThatAListenerGetsNotifiedIfSettingsForItsKeyAreSetNew
{
    NSDictionary *settingsForListener = @{
                                          @"SomeConfig" : @{
                                                  @"value" : @"SomeValue"
                                                  }
                                          };

    NSDictionary *configDictionary = @{ @"SomeOtherKey" : settingsForListener };

    MSActiveConfigMutableConfigurationState *configState = [self configStateWithConfigDictionary:configDictionary];

    id listener = [self listenerMock];

    [_activeConfig setNewConfigState:configState forUserID:nil];

    [_activeConfig registerListener:listener forSectionName:kSectionName];

    NSMutableDictionary *newSettings = [configDictionary mutableCopy];
    [newSettings setValue:@{@"SomeSettingKey" : @"SomeSettingValue"} forKey:kSectionName];
    MSActiveConfigMutableConfigurationState *newConfigState = [self configStateWithConfigDictionary:newSettings];
    MSActiveConfigSection *configSection = [MSActiveConfigSection configSectionWithDictionary:[newSettings valueForKey:kSectionName]];

    [[listener expect] activeConfig:_activeConfig didReceiveConfigSection:configSection forSectionName:kSectionName];

    [_activeConfig setNewConfigState:newConfigState forUserID:nil];

    WaitForNotificationsToBeDelivered();

    [listener verify];

    [_activeConfig removeListener:listener forSectionName:kSectionName];
}

- (void)testThatAListenerDoesntGetNotifiedIfActiveConfigGetsANewDictionaryWithTheSameConfigValues
{
    NSDictionary *settingsForListener = @{
                                          @"SomeConfig" : @{
                                                  @"value" : @"SomeValue"
                                                  }
                                          };

    NSDictionary *configDictionary = @{ kSectionName : settingsForListener };

    MSActiveConfigMutableConfigurationState *configState = [self configStateWithConfigDictionary:configDictionary];

    id listener = [self listenerMock];

    [_activeConfig setNewConfigState:configState forUserID:nil];

    WaitForNotificationsToBeDelivered();

    MSActiveConfigSection *configSection = [MSActiveConfigSection configSectionWithDictionary:settingsForListener];
    [[listener expect] activeConfig:_activeConfig didReceiveConfigSection:configSection forSectionName:kSectionName];

    [_activeConfig registerListener:listener forSectionName:kSectionName];

    WaitForNotificationsToBeDelivered();
    [listener verify];

    // Just a deep copy of the values
    NSMutableDictionary *newSettings = [configDictionary mutableCopy];
    [newSettings setValue:[[newSettings valueForKey:kSectionName] mutableCopy] forKey:kSectionName];
    MSActiveConfigMutableConfigurationState *newConfigState = [self configStateWithConfigDictionary:newSettings];

    [[listener reject] activeConfig:_activeConfig didReceiveConfigSection:configSection forSectionName:kSectionName];

    [_activeConfig setNewConfigState:newConfigState forUserID:nil];
    WaitForNotificationsToBeDelivered();

    [listener verify];

    [_activeConfig removeListener:listener forSectionName:kSectionName];
}

- (void)testThatAListenerGetsNotifiedIfSettingsForItsKeyGoAway
{
    NSDictionary *settingsForListener = @{
                                          @"SomeConfig" : @{
                                                  @"value" : @"SomeValue"
                                                  }
                                          };

    NSDictionary *configDictionary = @{ kSectionName : settingsForListener };
    MSActiveConfigMutableConfigurationState *configState = [self configStateWithConfigDictionary:configDictionary];

    id listener = [self listenerMock];

    [_activeConfig setNewConfigState:configState forUserID:nil];

    MSActiveConfigSection *configSection = [MSActiveConfigSection configSectionWithDictionary:settingsForListener];
    [[listener expect] activeConfig:_activeConfig didReceiveConfigSection:configSection forSectionName:kSectionName];

    [_activeConfig registerListener:listener forSectionName:kSectionName];
    WaitForNotificationsToBeDelivered();

    NSMutableDictionary *newSettings = [configDictionary mutableCopy];
    [newSettings removeObjectForKey:kSectionName];

    configSection = [MSActiveConfigSection configSectionWithDictionary:nil];
    MSActiveConfigMutableConfigurationState *newConfigState = [self configStateWithConfigDictionary:newSettings];

    [[listener expect] activeConfig:_activeConfig didReceiveConfigSection:configSection forSectionName:kSectionName];

    [_activeConfig setNewConfigState:newConfigState forUserID:nil];
    WaitForNotificationsToBeDelivered();

    [listener verify];

    [_activeConfig removeListener:listener forSectionName:kSectionName];
}

- (void)testThatAListenerIsOnlyNotifiedTheFirstTimeItsSettingsDisappear
{
    NSDictionary *settingsForListener = @{
                                          @"SomeConfig" : @{
                                                  @"value" : @"SomeValue"
                                                  }
                                          };

    NSDictionary *configDictionary = @{ kSectionName : settingsForListener };
    MSActiveConfigMutableConfigurationState *configState = [self configStateWithConfigDictionary:configDictionary];

    id listener = [self listenerMock];

    [_activeConfig setNewConfigState:configState forUserID:nil];

    MSActiveConfigSection *configSection = [MSActiveConfigSection configSectionWithDictionary:settingsForListener];
    [[listener expect] activeConfig:_activeConfig didReceiveConfigSection:configSection forSectionName:kSectionName];

    [_activeConfig registerListener:listener forSectionName:kSectionName];
    WaitForNotificationsToBeDelivered();

    NSMutableDictionary *newSettings = [configDictionary mutableCopy];
    [newSettings removeObjectForKey:kSectionName];
    MSActiveConfigMutableConfigurationState *newConfigState = [self configStateWithConfigDictionary:newSettings];

    configSection = [MSActiveConfigSection configSectionWithDictionary:nil];

    [[listener expect] activeConfig:_activeConfig didReceiveConfigSection:configSection forSectionName:kSectionName];

    [_activeConfig setNewConfigState:newConfigState forUserID:nil];
    WaitForNotificationsToBeDelivered();

    // Set the same settings again
    [[listener reject] activeConfig:_activeConfig didReceiveConfigSection:configSection forSectionName:kSectionName];
    [_activeConfig setNewConfigState:newConfigState forUserID:nil];
    WaitForNotificationsToBeDelivered();

    [listener verify];

    [_activeConfig removeListener:listener forSectionName:kSectionName];
}

#pragma mark - Config Bootstrapping

- (void)testThatDefaultConfigIsSentToListeners
{
    NSDictionary *settingsForListener = @{
                                          @"SomeConfig" : @{
                                                  @"value" : @"SomeValue"
                                                  }
                                          };

    NSDictionary *configDictionary = @{ kSectionName : settingsForListener };
    MSActiveConfigMutableConfigurationState *configState = [self configStateWithConfigDictionary:configDictionary];

    MSActiveConfigSection *configSection = [MSActiveConfigSection configSectionWithDictionary:settingsForListener];
    MSActiveConfig *activeConfig = [self activeConfigWithFakeDownloaderAndStoredState:configState];
    WaitForLastKnownConfigurationToBeLoaded();

    id listener = [self listenerMock];
    [[listener expect] activeConfig:activeConfig didReceiveConfigSection:configSection forSectionName:kSectionName];

    [activeConfig registerListener:listener forSectionName:kSectionName];
    WaitForNotificationsToBeDelivered();

    [listener verify];

    [activeConfig removeListener:listener forSectionName:kSectionName];
}

- (void)testThatSettingNewConfigurationHasPriorityOverDefaultSettings
{
    NSDictionary *defaultSettingsForListener = [NSDictionary dictionaryWithObject:@"SomeValue1" forKey:@"SomeyKey1"];
    NSDictionary *newSettingsForListener = [NSDictionary dictionaryWithObject:@"SomeValue2" forKey:@"SomeyKey2"];

    NSDictionary *defaultSettings = [NSDictionary dictionaryWithObject:defaultSettingsForListener forKey:kSectionName];
    NSDictionary *newSettings = [NSDictionary dictionaryWithObject:newSettingsForListener forKey:kSectionName];

    MSActiveConfigMutableConfigurationState *defaultConfigState = [self configStateWithConfigDictionary:defaultSettings];
    MSActiveConfigMutableConfigurationState *newConfigState = [self configStateWithConfigDictionary:newSettings];

    MSActiveConfigSection *configSectionForDefaultSettings = [MSActiveConfigSection configSectionWithDictionary:defaultSettingsForListener];
    MSActiveConfigSection *configSectionForNewSettings = [MSActiveConfigSection configSectionWithDictionary:newSettingsForListener];

    MSActiveConfig *activeConfig = [self activeConfigWithFakeDownloaderAndStoredState:defaultConfigState];

    id listener = [self listenerMock];

    [[listener expect] activeConfig:activeConfig didReceiveConfigSection:configSectionForDefaultSettings forSectionName:kSectionName];

    [activeConfig registerListener:listener forSectionName:kSectionName];
    WaitForNotificationsToBeDelivered();

    [[listener expect] activeConfig:activeConfig didReceiveConfigSection:configSectionForNewSettings forSectionName:kSectionName];

    [activeConfig setNewConfigState:newConfigState forUserID:nil];
    WaitForNotificationsToBeDelivered();

    [listener verify];

    [activeConfig removeListener:listener forSectionName:kSectionName];
}

#pragma mark - Downloading

- (void)testTheDownloaderIsAskedToDownloadNewConfig
{
    id downloader = [OCMockObject mockForProtocol:@protocol(MSActiveConfigDownloader)];

    NSString *userID = @"1";

    MSActiveConfig *activeConfig = [[MSActiveConfig alloc] initWithConfigDownloader:downloader configStore:nil];
    activeConfig.currentUserID = userID;

    __block BOOL downloadRequested = NO;

    [[[downloader expect] andDo:^(NSInvocation *inv) {
        downloadRequested = YES;
    }] requestActiveConfigForUserWithID:userID error:(NSError *__autoreleasing *)[OCMArg anyPointer]];

    [activeConfig downloadNewConfig];

    double timeout = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        STAssertTrue(downloadRequested, @"The downloader should've been requested to download the config by now");
        downloadRequested = YES;
    });

    MSTestWaitUntilTrue(downloadRequested);

    [downloader verify];
}

- (void)testTheDownloadedSettingsAreSet
{
    NSDictionary *downloadedSettings = [self sampleDownloadedSettings];

    id downloader = [OCMockObject mockForProtocol:@protocol(MSActiveConfigDownloader)];

    NSString *userID = @"1";

    MSActiveConfig *activeConfig = [[MSActiveConfig alloc] initWithConfigDownloader:downloader configStore:nil];
    activeConfig.currentUserID = userID;

    [[[downloader expect] andReturn:downloadedSettings] requestActiveConfigForUserWithID:userID error:(NSError *__autoreleasing *)[OCMArg anyPointer]];

    [activeConfig downloadNewConfig];

    __block BOOL settingsWhereSet = NO;

    double timeout = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        STAssertEqualObjects(activeConfig.configDictionary, [downloadedSettings valueForKey:@"config_sections"], @"Should set the downloaded settings");
        settingsWhereSet = YES;
    });

    MSTestWaitUntilTrue(settingsWhereSet);

    [downloader verify];
}

- (void)testActiveConfigPostsANotificationTheFirstTimeItDownloadsConfig
{
    id downloader = [OCMockObject mockForProtocol:@protocol(MSActiveConfigDownloader)];
    id observer = [OCMockObject observerMock];

    NSNumber *userID = @"1";

    MSActiveConfig *activeConfig = [[MSActiveConfig alloc] initWithConfigDownloader:downloader configStore:nil];
    activeConfig.currentUserID = userID;

    [[NSNotificationCenter defaultCenter] addMockObserver:observer name:MSActiveConfigFirstDownloadFinishedNotification object:activeConfig];

    [[observer expect] notificationWithName:MSActiveConfigFirstDownloadFinishedNotification object:activeConfig];

    [self expectConfigDownloadInActiveConfig:activeConfig userID:userID];

    [observer verify];

    // Download again and check it doesn't get the notification again
    
    [self expectConfigDownloadInActiveConfig:activeConfig userID:userID];
}

#pragma mark -

- (void)testActiveConfigIgnoresSomethingThatIsNotADictionary
{
    NSNumber *invalidSettingsDictionary = @"1";
    MSActiveConfigMutableConfigurationState *configState = [self configStateWithConfigDictionary:(id)invalidSettingsDictionary];
    
    // Nothing should happen
    [_activeConfig setNewConfigState:configState forUserID:nil];
}

// APP-525
- (void)testActiveConfigIgnoresNonDictionaryValues
{
    NSString *configKey = @"ConfigKey";
    NSString *configValueWhichIsNotADict = @"ConfigValue";
    
    NSDictionary *downloadedSettings = [NSDictionary dictionaryWithObject:configValueWhichIsNotADict forKey:configKey];
    MSActiveConfigMutableConfigurationState *configState = [self configStateWithConfigDictionary:downloadedSettings];
    
    [_activeConfig setNewConfigState:configState forUserID:nil];
    
    STAssertFalse([[_activeConfig.configDictionary valueForKey:configKey] isEqual:configValueWhichIsNotADict], @"It should ignore the value cause everything expects a dictionary!");
}

#pragma mark - 

- (void)testAskingForAConfigSectionWorks
{
    NSString *settingKey = @"someKey";
    NSString *settingValue = @"SomeValue";
    
    NSDictionary *settingsForListener = @{
                                          @"settings" : @{
                                                  settingKey : @{
                                                          @"value" : settingValue
                                                          }
                                                  }
                                          };
    
    NSDictionary *configDictionary = @{ kSectionName : settingsForListener };
    
    MSActiveConfigMutableConfigurationState *configState = [self configStateWithConfigDictionary:configDictionary];
    [_activeConfig setNewConfigState:configState forUserID:nil];
    
    MSActiveConfigSection *retrievedConfigSection = [_activeConfig configSectionWithName:kSectionName];
    
    STAssertNotNil(retrievedConfigSection, @"Should get a config section");
    STAssertEqualObjects([retrievedConfigSection stringForKey:settingKey], settingValue, @"Should get the value");
}

- (void)testAskingForAConfigSectionReturnsNilIfThereIsNoConfigForThatKey
{
    NSDictionary *configDictionary = @{};
    
    MSActiveConfigMutableConfigurationState *configState = [self configStateWithConfigDictionary:configDictionary];
    [_activeConfig setNewConfigState:configState forUserID:nil];
    
    MSActiveConfigSection *retrievedConfigSection = [_activeConfig configSectionWithName:kSectionName];
    
    STAssertNil(retrievedConfigSection, @"Should get a nil config section");
}

@end
