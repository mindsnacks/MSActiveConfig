//
//  MSActiveConfigConfigurationState.h
//  MSActiveConfig
//
//  Created by Javier Soto on 8/13/12.
//
//

@class MSTimestamp;
@class MSActiveConfigSection;

@class MSActiveConfigMutableConfigurationState;

/**
 * @discussion for a mutable version of this class see `MSActiveConfigMutableConfigurationState`
 * Objects of this class are not mutable and therefor safe to use from different threads.
 */
@interface MSActiveConfigConfigurationState : NSObject <NSCopying, NSMutableCopying, NSSecureCoding>

@property (nonatomic, readonly, copy) NSString *creationDateString;
@property (nonatomic, readonly, copy) NSString *formatVersion;
@property (nonatomic, readonly, copy) NSDictionary *meta;
@property (nonatomic, readonly, copy) NSDictionary *configurationDictionary;

/**
 * @return a populated MSActiveConfigConfigurationState with the values in the dictionary returned by active config server,
 * or nil if it can't parse the dictionary (for example if the format version is invalid).
 */
- (id)initWithDictionary:(NSDictionary *)dictionary;

- (MSActiveConfigConfigurationState *)copy;
- (MSActiveConfigMutableConfigurationState *)mutableCopy;

/**
 * @return an `activeConfigSection` object with the settings in this active config state or nil if non present.
 */
- (MSActiveConfigSection *)configSectionWithName:(NSString *)configSection;

/**
 * @return an array of strings containing all the config section keys in this configuration state
 */
- (NSArray *)configSectionNames;

@end
