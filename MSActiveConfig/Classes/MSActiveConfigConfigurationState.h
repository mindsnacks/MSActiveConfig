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
 Objects of this class are not mutable and therefor safe to use from different threads.
 
 ## Mutability and Thread-Safety
 `MSActiveConfigConfigurationState` is an immutable object, so it's safe to use from different threads without locking.
 
 For a mutable version of this class see `MSActiveConfigMutableConfigurationState`.
 */

@interface MSActiveConfigConfigurationState : NSObject <NSCopying, NSSecureCoding>

///----------------------------
/// @name Properties
///----------------------------

/**
 The string contained in the configuration state meta headers that represents the date when this state was generated.
 Just for debug purposes.
 */
@property (nonatomic, readonly, copy) NSString *creationDateString;

/**
 The version indicated in the configuration state meta headers.
 */
@property (nonatomic, readonly, copy) NSString *formatVersion;

/**
 The dictionary containing all the meta headers when parsing the dictionary this object was created with.
 */
@property (nonatomic, readonly, copy) NSDictionary *meta;

///----------------------------
/// @name Initialization
///----------------------------

/**
 Designated Initializer. It returns a populated `MSActiveConfigConfigurationState` with the values in the dictionary.
 @return An initialized `MSActiveConfigConfigurationState` object with the data in the provided dictionary
 or `nil` if it has an invalid format.
 @note If `dictionary` is nil, it will return an object with no configuration sections.
 */
- (id)initWithDictionary:(NSDictionary *)dictionary;

///----------------------------
/// @name Querying the Contents
///----------------------------

/**
 Returns an `MSActiveConfigSection` object with the settings in this active config state or `nil`.
 @param configSectionName (required) The name for the section within this configuration state.
 @note Refer to the Configuration Exchange Format documentation to understand the different parts of the configuration document.
 */
- (MSActiveConfigSection *)configSectionWithName:(NSString *)configSectionName;

/**
 Returns an array of strings with all the config section names in this configuration state.
 */
- (NSArray *)configSectionNames;

@end
