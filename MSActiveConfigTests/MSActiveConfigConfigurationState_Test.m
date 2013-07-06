//
//  MSActiveConfigConfigurationState_Test.m
//  MSActiveConfig
//
//  Created by Javier Soto on 8/13/12.
//
//

#import "MSActiveConfig_BaseTest.h"

#import "MSActiveConfigConfigurationState.h"
#import "MSActiveConfigMutableConfigurationState.h"

@interface MSActiveConfigConfigurationState_Test : MSActiveConfig_BaseTest

@end


@implementation MSActiveConfigConfigurationState_Test

- (void)assertConfigState:(MSActiveConfigConfigurationState *)state1 isEqualToState:(MSActiveConfigConfigurationState *)state2
{
    STAssertNotNil(state1, @"Should not be nil");
    STAssertNotNil(state2, @"Should not be nil");
    STAssertEqualObjects(state1.formatVersion, state2.formatVersion, @"Format version should be the same.");
    STAssertEqualObjects(state1.configurationDictionary, state2.configurationDictionary, @"Should have the same config.");
    STAssertEqualObjects(state1.creationDateString, state2.creationDateString, @"Should have the same date.");
}

#pragma mark - Tests

- (void)testANilDictionaryReturnsAnInitializedObjectWithNoData
{
    MSActiveConfigConfigurationState *configState = [[MSActiveConfigConfigurationState alloc] init];

    STAssertEquals([configState.formatVersion intValue], 1, @"Format version should be 1");
    STAssertNotNil(configState.creationDateString, @"Should have current date");
    STAssertEquals(configState.configurationDictionary.count, (NSUInteger)0, @"Should have an empty dictionary");
    STAssertTrue([configState.configurationDictionary isKindOfClass:[NSDictionary class]], @"Should have a non mutable dictionary");
}

- (void)testANilDictionaryReturnsAnInitializedObjectWithNoDataMutable
{
    MSActiveConfigMutableConfigurationState *configState = [[MSActiveConfigMutableConfigurationState alloc] init];

    STAssertEquals([configState.formatVersion intValue], 1, @"Format version should be 1");
    STAssertNotNil(configState.creationDateString, @"Should have current date");
    STAssertEquals(configState.configurationDictionary.count, (NSUInteger)0, @"Should have an empty dictionary");
    STAssertTrue([configState.configurationDictionary isKindOfClass:[NSMutableDictionary class]], @"Should have a mutable dictionary");
}

- (void)testMutableConfigurationStateCopiesAsANonMutable
{
    MSActiveConfigMutableConfigurationState *configState = [[MSActiveConfigMutableConfigurationState alloc] init];

    MSActiveConfigConfigurationState *configStateCopy = [configState copy];

    STAssertTrue([configStateCopy isMemberOfClass:[MSActiveConfigConfigurationState class]], @"Should be an immutable object");
}

- (void)testMutableCopyReturnsAMutableCopy
{
    MSActiveConfigConfigurationState *configState = [[MSActiveConfigConfigurationState alloc] init];

    MSActiveConfigMutableConfigurationState *configStateCopy = [configState mutableCopy];

    STAssertTrue([configStateCopy isMemberOfClass:[MSActiveConfigMutableConfigurationState class]], @"Should be a mutable object");
}

- (void)testANonDictionaryMakesItReturnNil
{
    NSNumber *nonDictionaryObject = @1;

    MSActiveConfigConfigurationState *configState = [[MSActiveConfigConfigurationState alloc] initWithDictionary:(id)nonDictionaryObject];

    STAssertNil(configState, @"Should return nil");
}

- (void)testANonNumericValueForFormatVersionMakesItReturnNil
{
    NSDictionary *configDictionary = @{ @"meta" : @{ @"format_version" : @"this_is_not_a_number" } };

    MSActiveConfigConfigurationState *configState = [[MSActiveConfigConfigurationState alloc] initWithDictionary:configDictionary];

    STAssertNil(configState, @"Should return nil");
}

- (void)testAnInvalidFormatVersionValueMakesItReturnNil
{
    NSDictionary *configDictionary = @{ @"meta" : @{ @"format_version" : @100 } };

    MSActiveConfigConfigurationState *configState = [[MSActiveConfigConfigurationState alloc] initWithDictionary:configDictionary];

    STAssertNil(configState, @"Should return nil");
}

- (void)testANonDictionaryConfigDictionaryMakesItReturnNil
{
    NSDictionary *configDictionary = @{
        @"meta" : @{
            @"format_version_string" : @"1"
        },
        @"config_sections" : @"this_is_not_a_dictionary"
    };

    MSActiveConfigConfigurationState *configState = [[MSActiveConfigConfigurationState alloc] initWithDictionary:configDictionary];

    STAssertNil(configState, @"Should return nil");
}

- (void)testANonDictionaryMetaMakesItReturnNil
{
    NSDictionary *configDictionary = @{
        @"meta" : @1,
        @"config_sections" : @{}
    };

    MSActiveConfigConfigurationState *configState = [[MSActiveConfigConfigurationState alloc] initWithDictionary:configDictionary];

    STAssertNil(configState, @"Should return nil");
}

- (void)testAValidConfigurationDictionarySetsAllTheValues
{
    NSDictionary *config = @{
        @"SomeKey" : @"SomeValue"
    };
    NSString *formatVersion = @"1";
    NSString *creationDateString = [[NSDate date] description];

    NSDictionary *configDictionary = @{
        @"meta" : @{
            @"format_version_string" : formatVersion,
            @"creation_time" : creationDateString
        },
        @"config_sections" : config,
    };

    MSActiveConfigConfigurationState *configState = [[MSActiveConfigConfigurationState alloc] initWithDictionary:configDictionary];

    STAssertNotNil(configState, @"Should not return nil");
    STAssertEqualObjects(configState.formatVersion, formatVersion, @"Format version should be the same.");
    STAssertEqualObjects(configState.configurationDictionary, config, @"Should have the same config.");
    STAssertEqualObjects(configState.creationDateString, creationDateString, @"Should have the same date.");
}

- (void)testNSCopying
{
    NSDictionary *config = @{
        @"SomeKey" : @"SomeValue"
    };
    NSString *formatVersion = @"1.0";

    NSDictionary *configDictionary = @{
        @"meta" : @{
            @"creation_time" : [[NSDate date] description],
            @"format_version_string" : formatVersion,
        },
        @"config_sections" : config,
    };

    MSActiveConfigConfigurationState *configState = [[MSActiveConfigConfigurationState alloc] initWithDictionary:configDictionary];

    MSActiveConfigConfigurationState *configStateCopy = [configState copy];

    [self assertConfigState:configState isEqualToState:configStateCopy];
}

- (void)testNSCoding
{
    NSDictionary *config = @{
        @"SomeKey" : @"SomeValue"
    };
    NSString *formatVersion = @"1";

    NSDictionary *configDictionary = @{
        @"meta" : @{
            @"creation_time" : [[NSDate date] description],
            @"format_version_string" : formatVersion
        },
        @"config_sections" : config,
    };

    MSActiveConfigConfigurationState *configState = [[MSActiveConfigConfigurationState alloc] initWithDictionary:configDictionary];

    NSData *encodedConfigState = [NSKeyedArchiver archivedDataWithRootObject:configState];
    MSActiveConfigConfigurationState *decodedConfigState = [NSKeyedUnarchiver unarchiveObjectWithData:encodedConfigState];

    [self assertConfigState:configState isEqualToState:decodedConfigState];
}

@end
