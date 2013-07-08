//
//  MSActiveConfigConfigurationState.m
//  MSActiveConfig
//
//  Created by Javier Soto on 8/13/12.
//
//

#import "MSActiveConfigConfigurationState.h"
#import "MSActiveConfigSection+Private.h"

#import "MSActiveConfigMutableConfigurationState.h"

static NSString *const MSActiveConfigConfigurationStateMetaKey = @"meta";
static NSString *const MSActiveConfigConfigurationStateFormatVersionKey = @"format_version_string";
static NSString *const MSActiveConfigConfigurationStateConfigurationDictionaryKey = @"config_sections";
static NSString *const MSActiveConfigConfigurationStateCreationTimeKey = @"creation_time";

@interface MSActiveConfigConfigurationState ()

@property (nonatomic, readwrite, copy) NSString *creationDateString;
@property (nonatomic, readwrite, copy) NSString *formatVersion;
@property (nonatomic, readwrite, copy) NSDictionary *meta;
@property (nonatomic, readwrite, copy) NSDictionary *configurationDictionary;

@end

@implementation MSActiveConfigConfigurationState

- (id)init
{
    return [self initWithDictionary:nil];
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if ((self = [super init]))
    {
        BOOL anyError = NO;

        if (dictionary != nil)
        {
            if ([dictionary isKindOfClass:[NSDictionary class]])
            {
                id metaObject = [dictionary valueForKey:MSActiveConfigConfigurationStateMetaKey];

                if ([metaObject isKindOfClass:[NSDictionary class]])
                {
                    id formatVersionObject = [metaObject valueForKey:MSActiveConfigConfigurationStateFormatVersionKey];

                    NSDictionary *configDictionary = [dictionary valueForKey:MSActiveConfigConfigurationStateConfigurationDictionaryKey];

                    if ([configDictionary isKindOfClass:[NSDictionary class]])
                    {
                        self.formatVersion = formatVersionObject ?: @"";
                        self.configurationDictionary = configDictionary;
                        self.creationDateString = [metaObject valueForKey:MSActiveConfigConfigurationStateCreationTimeKey];

                        self.meta = metaObject;
                    }
                    else
                    {
                        NSLog(@"Active config returned a non-dictionary configuration \"%@\"", configDictionary);
                        anyError = YES;
                    }
                }
                else
                {
                    NSLog(@"Active config dictionary received contained invalid meta object \"%@\"", dictionary);
                    anyError = YES;
                }
            }
            else
            {
                NSLog(@"Active config returned a non-dictionary object \"%@\"", dictionary);
                anyError = YES;
            }
            
            if (anyError)
            {
                self = nil;
                return nil;
            }
        }
        else
        {
            self.formatVersion = @"1.0";
            self.creationDateString = [[NSDate date] description];
            self.meta = @{};
            self.configurationDictionary = @{};
        }
    }

    return self;
}

- (MSActiveConfigSection *)configSectionWithName:(NSString *)sectionName
{
    return [[MSActiveConfigSection alloc] initWithDictionary:[self.configurationDictionary objectForKey:sectionName]];
}

- (NSArray *)configSectionNames
{
    return self.configurationDictionary.allKeys;
}

#pragma mark - 

- (NSString *)description
{
    return [NSString stringWithFormat:@"Format version: %@\nGenerated Time: %@\nMeta: %@\nConfiguration Dictionary:\n%@", self.formatVersion, self.creationDateString, self.meta, self.configurationDictionary];
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }

    if (![object isKindOfClass:[MSActiveConfigConfigurationState class]])
    {
        return NO;
    }

    MSActiveConfigConfigurationState *configState = object;

    return (((configState.configurationDictionary == self.configurationDictionary) || ([configState.configurationDictionary isEqual:self.configurationDictionary])) &&
            ((configState.meta == self.meta) || ([configState.meta isEqual:self.meta])));
}

- (NSUInteger)hash
{
    return [self.configurationDictionary hash] * [self.meta hash];
}

#pragma mark - NSSecureCoding

static inline id MSActiveConfigDecodeObjectWithKnownClass(NSCoder *decoder, NSString *key, Class expectedClass, id fallbackObject)
{
    @try
    {
        return [decoder decodeObjectOfClass:expectedClass forKey:key] ?: fallbackObject;
    }
    @catch (NSException *exception)
    {
        NSLog(@"Error decoding object for key %@ expecting class %@ (%@)", key, NSStringFromClass(expectedClass), exception);
        
        return fallbackObject;
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init]))
    {
        self.formatVersion = MSActiveConfigDecodeObjectWithKnownClass(aDecoder, MSActiveConfigConfigurationStateFormatVersionKey, [NSString class], @"");
        self.creationDateString = MSActiveConfigDecodeObjectWithKnownClass(aDecoder, MSActiveConfigConfigurationStateCreationTimeKey, [NSString class], @"");
        self.meta = MSActiveConfigDecodeObjectWithKnownClass(aDecoder, MSActiveConfigConfigurationStateMetaKey, [NSDictionary class], @{});
        self.configurationDictionary = MSActiveConfigDecodeObjectWithKnownClass(aDecoder, MSActiveConfigConfigurationStateConfigurationDictionaryKey, [NSDictionary class], @{});
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.formatVersion forKey:MSActiveConfigConfigurationStateFormatVersionKey];
    [aCoder encodeObject:self.creationDateString forKey:MSActiveConfigConfigurationStateCreationTimeKey];
    [aCoder encodeObject:self.meta forKey:MSActiveConfigConfigurationStateMetaKey];
    [aCoder encodeObject:self.configurationDictionary forKey:MSActiveConfigConfigurationStateConfigurationDictionaryKey];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - NSCopying

- (MSActiveConfigConfigurationState *)copy
{
    return [self copyWithZone:nil];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
