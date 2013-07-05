//
//  MSConfigSection_Test.m
//  MSAppKit
//
//  Created by Javier Soto on 6/27/12.
//  Copyright (c) 2012 MindSnacks. All rights reserved.
//

#import "MSActiveConfig_BaseTest.h"

#import "MSActiveConfigSection.h"
#import "MSActiveConfigSection+Private.h"

#define kKey @"Key"

@interface MSConfigSection_Test : MSActiveConfig_BaseTest

@end

@implementation MSConfigSection_Test

- (MSActiveConfigSection *)configSectionWithObject:(id)object forKey:(NSString *)key
{
    MSActiveConfigSection *c = [MSActiveConfigSection configSectionWithDictionary:@{
                                @"settings" : @{
                                     key : @{
                                        @"value" : object
                                    }
                                }
                            }];

    return c;
}

#pragma mark - Tests

- (void)TestThatAnyObjectCanBeReturned
{
    id object = [[NSObject alloc] init];   
    
    MSActiveConfigSection *c = [self configSectionWithObject:object forKey:kKey];
    
    STAssertEquals([c stringForKey:kKey], object, @"Should return the object");
}

- (void)testThatAStringIsReturnedWhenAskedForIt
{
    NSString *string = @"String";
    
    MSActiveConfigSection *c = [self configSectionWithObject:string forKey:kKey];
    
    STAssertEquals([c stringForKey:kKey], string, @"Should return the string");
}

- (void)testThatAnotherTypeOfObjectIsNotReturnedWhenAskedForAString
{
    NSNumber *number = @3;
    
    MSActiveConfigSection *c = [self configSectionWithObject:number forKey:kKey];
    
    STAssertNil([c stringForKey:kKey], @"Shouldn't return anything");
}

- (void)testThatADictionaryIsNotReturnedForAnArray
{
    NSDictionary *dictionary = @{ @"SomeKey" : @"SomeObject" };
    
    MSActiveConfigSection *c = [self configSectionWithObject:dictionary forKey:kKey];
    
    STAssertNil([c arrayForKey:kKey], @"Shouldn't return anything");
}

- (void)testThatAnArrayIsNotReturnedForDictionary
{
    NSArray *array = @[@"oneObject", @"anotherObject"];
    
    MSActiveConfigSection *c = [self configSectionWithObject:array forKey:kKey];
    
    STAssertNil([c dictionaryForKey:kKey], @"Shouldn't return anything");
}

- (void)testThatADictionaryIsReturnedWhenAskedForIt
{
    NSDictionary *dictionary = @{ @"SomeKey" : @"SomeObject" };

    MSActiveConfigSection *c = [self configSectionWithObject:dictionary forKey:kKey];
    
    STAssertEquals([c dictionaryForKey:kKey], dictionary, @"Should return the dictionary");
}

- (void)testThatAnArrayIsReturnedWhenAskedForIt
{
    NSArray *array = @[@"oneObject", @"anotherObject"];

    MSActiveConfigSection *c = [self configSectionWithObject:array forKey:kKey];
    
    STAssertEquals([c arrayForKey:kKey], array, @"Should return the array");
}

- (void)testAnArrayOfOtherThanStringsIsNotReturnedWhenAskedForAnArrayOfStrings
{
    id object = [[NSObject alloc] init];
    NSArray *array = @[object, object];
    
    MSActiveConfigSection *c = [self configSectionWithObject:array forKey:kKey];
    
    STAssertNil([c stringArrayForKey:kKey], @"Shouldn't return anything");
}

- (void)testAnArrayOfStringsIsReturnedWhenAskedForIt
{
    NSArray *array = @[@"One string", @"Another string"];
    
    MSActiveConfigSection *c = [self configSectionWithObject:array forKey:kKey];
    
    STAssertEquals([c stringArrayForKey:kKey], array, @"Should return the array");
}

- (void)testAFormedURLIsReturnedWhenAskedForItIfTheDictionaryHasAString
{
    NSString *urlString = @"http://www.url.com/";
    
    MSActiveConfigSection *c = [self configSectionWithObject:urlString forKey:kKey];
    
    STAssertEquals([[c URLForKey:kKey] absoluteString], urlString, @"Should return the correct URL");
}

- (void)testAnURLIsReturnedWhenAskedForIt
{
    NSString *urlString = @"http://www.url.com/";
    NSURL *url = [NSURL URLWithString:urlString];
    
    MSActiveConfigSection *c = [self configSectionWithObject:url forKey:kKey];
    
    STAssertEquals([c URLForKey:kKey], url, @"Should return the URL");
}

- (void)testAnIntegerIsReturnedWhenAskedForIt
{
    NSInteger integer = 10;
    
    MSActiveConfigSection *c = [self configSectionWithObject:@(integer) forKey:kKey];
    
    STAssertEquals([c integerForKey:kKey], integer, @"Should return the integer");
}

- (void)testZeroIsReturnedIfAskedForAnIntergerAndTheresSomethingElse
{
    NSArray *array = @[@"oneObject", @"anotherObject"];
    
    MSActiveConfigSection *c = [self configSectionWithObject:array forKey:kKey];
    
    STAssertEquals([c integerForKey:kKey], 0, @"Should return 0");
}

- (void)testZeroIsReturnedIfAskedForAFloatAndTheresSomethingElse
{
    NSArray *array = @[@"oneObject", @"anotherObject"];
    
    MSActiveConfigSection *c = [self configSectionWithObject:array forKey:kKey];
    
    STAssertEquals([c floatForKey:kKey], 0.0f, @"Should return 0.0");
}

- (void)testZeroIsReturnedIfAskedForADoubleAndTheresSomethingElse
{
    NSArray *array = @[@"oneObject", @"anotherObject"];
    
    MSActiveConfigSection *c = [self configSectionWithObject:array forKey:kKey];
    
    STAssertEquals([c doubleForKey:kKey], 0.0, @"Should return 0.0");
}

- (void)testNOIsReturnedIfAskedForABOOLAndTheresSomethingElse
{
    NSArray *array = @[@"oneObject", @"anotherObject"];
    
    MSActiveConfigSection *c = [self configSectionWithObject:array forKey:kKey];
    
    STAssertEquals([c boolForKey:kKey], NO, @"Should return NO");
}

- (void)testTheIntegerIsReturnedIfAskedForItAndItHasAStringWithThatNumber
{
    NSString *string = @"45";
    
    MSActiveConfigSection *c = [self configSectionWithObject:string forKey:kKey];
    
    STAssertEquals([c integerForKey:kKey], 45, @"Should return %@", string);
}

- (void)testAFloatIsReturnedIfAskedForIt
{
    float floatNumber = 1.2f;
    
    MSActiveConfigSection *c = [self configSectionWithObject:@(floatNumber) forKey:kKey];
    
    STAssertEquals([c floatForKey:kKey], 1.2f, @"Should return the float");
}

- (void)testADoubleIsReturnedIfAskedForIt
{
    double doubleNumber = 10.1;
    
MSActiveConfigSection *c = [self configSectionWithObject:@(doubleNumber) forKey:kKey];
    
    STAssertEquals([c doubleForKey:kKey], 10.1, @"Should return the double");
}

- (void)testThatAnIntegerIsReturnedIfItHasAFloat
{
    float floatNumber = 10.3f;
    
MSActiveConfigSection *c = [self configSectionWithObject:@(floatNumber) forKey:kKey];
    
    STAssertEquals([c integerForKey:kKey], 10, @"Should return the integer");
}

- (void)testThatABoolYESIsReturnedIfAskedForIt
{
    BOOL yes = YES;
    
MSActiveConfigSection *c = [self configSectionWithObject:@(yes) forKey:kKey];
    
    STAssertEquals([c boolForKey:kKey], yes, @"Should return YES");
}

- (void)testThatABoolNOIsReturnedIfAskedForIt
{
    BOOL no = NO;
    
MSActiveConfigSection *c = [self configSectionWithObject:@(no) forKey:kKey];
    
    STAssertEquals([c boolForKey:kKey], no, @"Should return NO");
}

@end
