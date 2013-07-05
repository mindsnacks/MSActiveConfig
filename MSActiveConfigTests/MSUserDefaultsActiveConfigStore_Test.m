//
//  MSUserDefaultsActiveConfigStore_Test.m
//  MSAppKit
//
//  Created by Javier Soto on 6/27/12.
//  Copyright (c) 2012 MindSnacks. All rights reserved.
//

#import "MSActiveConfig_BaseTest.h"

#import "MSActiveConfig_BaseTest.h"

#import "MSActiveConfigMutableConfigurationState.h"
#import "MSUserDefaultsActiveConfigStore.h"

@interface MSUserDefaultsActiveConfigStore_Test : MSActiveConfig_BaseTest
{
    NSUserDefaults *_userDefaults;
    NSString *_userID;

    MSUserDefaultsActiveConfigStore *_store;
}
@end

@implementation MSUserDefaultsActiveConfigStore_Test

- (void)setUp
{
    [super setUp];

    _userDefaults = [[NSUserDefaults alloc] init];

    _userID = @1234;

    MSClearAllNSUserDefaults();

    _store = [[MSUserDefaultsActiveConfigStore alloc] initWithUserDefaults:_userDefaults
                                                initialSharedConfiguration:nil];
}

- (void)tearDown
{
    _userDefaults = nil;
    _store = nil;
    
    [super tearDown];
}

#pragma mark - Tests

- (void)testThatConfigurationCanBePersisted
{
    MSActiveConfigMutableConfigurationState *someConfiguration = [self configStateWithConfigDictionary:[NSDictionary dictionaryWithObject:@"SomeValue" forKey:@"SomeKey"]];

    [_store persistConfiguration:someConfiguration forUserID:_userID];

    STAssertEqualObjects(someConfiguration, [_store lastKnownActiveConfigurationForUserID:_userID], @"Should return the previously provided dictionary");
}

- (void)testThatTellingToPersistNilConfigurationRemovesTheValue
{
    MSActiveConfigMutableConfigurationState *someConfiguration = [self configStateWithConfigDictionary:[NSDictionary dictionaryWithObject:@"SomeValue" forKey:@"SomeKey"]];

    [_store persistConfiguration:someConfiguration forUserID:_userID];

    STAssertEqualObjects(someConfiguration, [_store lastKnownActiveConfigurationForUserID:_userID], @"Should return the previously provided dictionary");

    [_store persistConfiguration:nil forUserID:_userID];

    STAssertNil([_store lastKnownActiveConfigurationForUserID:_userID], @"Should be nil now");
}

- (void)testThatRequestingTheConfigForAnotherUserDoesntReturnTheOriginal
{
    MSActiveConfigMutableConfigurationState *someConfiguration = [self configStateWithConfigDictionary:[NSDictionary dictionaryWithObject:@"SomeValue" forKey:@"SomeKey"]];

    [_store persistConfiguration:someConfiguration forUserID:_userID];

    NSString *otherUserID = @"999";

    STAssertFalse([[_store lastKnownActiveConfigurationForUserID:otherUserID] isEqual:someConfiguration], @"Shouldn't return the same configuration!");
}

- (void)testTheInitialSettingsAreReturnedIfItDoesntGetAnyUpdatedConfig
{
    MSActiveConfigMutableConfigurationState *initialConfiguration = [self configStateWithConfigDictionary:[NSDictionary dictionaryWithObject:@"SomeValue" forKey:@"SomeKey"]];

    MSUserDefaultsActiveConfigStore *store = [[MSUserDefaultsActiveConfigStore alloc] initWithUserDefaults:_userDefaults
                                                                                 initialSharedConfiguration:initialConfiguration];

    STAssertEqualObjects([store lastKnownActiveConfigurationForUserID:_userID], initialConfiguration, @"Should return the initial configuration");
}

- (void)testTheInitialSharedSettingsAreSharedAmongUsers
{
    MSActiveConfigMutableConfigurationState *initialConfiguration = [self configStateWithConfigDictionary:[NSDictionary dictionaryWithObject:@"SomeValue" forKey:@"SomeKey"]];

    NSString *userID1 = @"1";
    NSString *userID2 = @"2";

    MSUserDefaultsActiveConfigStore *store = [[MSUserDefaultsActiveConfigStore alloc] initWithUserDefaults:_userDefaults
                                                                                 initialSharedConfiguration:initialConfiguration];


    STAssertEqualObjects([store lastKnownActiveConfigurationForUserID:userID1], initialConfiguration, @"Should return the same initial configuration");
    STAssertEqualObjects([store lastKnownActiveConfigurationForUserID:userID2], initialConfiguration, @"Should return the same initial configuration");
}

- (void)testPersistingConfigurationOverridesTheSharedInitialConfiguration
{
    MSActiveConfigMutableConfigurationState *initialConfiguration = [self configStateWithConfigDictionary:[NSDictionary dictionaryWithObject:@"SomeValue" forKey:@"SomeKey"]];
    MSActiveConfigMutableConfigurationState *updatedConfiguration = [self configStateWithConfigDictionary:[NSDictionary dictionaryWithObject:@"SomeValue2" forKey:@"SomeKey2"]];

    MSUserDefaultsActiveConfigStore *store = [[MSUserDefaultsActiveConfigStore alloc] initWithUserDefaults:_userDefaults
                                                                                initialSharedConfiguration:initialConfiguration];

    [store persistConfiguration:updatedConfiguration forUserID:_userID];

    STAssertEqualObjects([store lastKnownActiveConfigurationForUserID:_userID], updatedConfiguration, @"Should return the initial configuration");
}

- (void)testThatChangingTheUserMakesItFallbackToTheInitialConfigurationIfTheresNoUpdatedNilUserConfig
{
    MSActiveConfigMutableConfigurationState *initialConfiguration = [self configStateWithConfigDictionary:[NSDictionary dictionaryWithObject:@"SomeValue" forKey:@"SomeKey"]];

    MSUserDefaultsActiveConfigStore *store = [[MSUserDefaultsActiveConfigStore alloc] initWithUserDefaults:_userDefaults
                                                                                 initialSharedConfiguration:initialConfiguration];

    MSActiveConfigConfigurationState *lastKnownConfigurationNow = [store lastKnownActiveConfigurationForUserID:_userID];

    STAssertEqualObjects(lastKnownConfigurationNow, initialConfiguration, @"Should fallback to the initial configuration");
}

- (void)testThatChangingTheUserMakesItFallBackToTheNilUserConfigRatherThanTheSharedInitialConfig
{
    MSActiveConfigMutableConfigurationState *initialConfiguration = [self configStateWithConfigDictionary:[NSDictionary dictionaryWithObject:@"SomeValue" forKey:@"SomeKey"]];

    MSActiveConfigMutableConfigurationState *updatedConfigurationForNilUser = [self configStateWithConfigDictionary:[NSDictionary dictionaryWithObject:@"SomeValue2" forKey:@"SomeKey2"]];

    MSUserDefaultsActiveConfigStore *store = [[MSUserDefaultsActiveConfigStore alloc] initWithUserDefaults:_userDefaults
                                                                                initialSharedConfiguration:initialConfiguration];

    [store persistConfiguration:updatedConfigurationForNilUser forUserID:nil];


    MSActiveConfigConfigurationState *lastKnownConfigurationNow = [store lastKnownActiveConfigurationForUserID:_userID];
    
    STAssertFalse([lastKnownConfigurationNow isEqual:initialConfiguration], @"Shouldn't return the initial configuration since there's updated configuration for the nil user.");
    STAssertEqualObjects(lastKnownConfigurationNow, updatedConfigurationForNilUser, @"Should return the nil user configuration");
}

@end
