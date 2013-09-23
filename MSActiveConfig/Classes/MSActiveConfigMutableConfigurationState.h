//
//  MSActiveConfigMutableConfigurationState.h
//  MSActiveConfig
//
//  Created by Javier Soto on 5/14/13.
//
//

#import "MSActiveConfigConfigurationState.h"

/**
 This subclass of `MSActiveConfigConfigurationState` provides the same properties, but they're readonly.
 
 Also the `configurationDictionary` property is an `NSMutableDictionary`.
 
 You will rarely need to use this class directly.
 */

@interface MSActiveConfigMutableConfigurationState : MSActiveConfigConfigurationState

@property (nonatomic, readwrite, copy) NSString *creationDateString;
@property (nonatomic, readwrite, copy) NSString *formatVersion;
@property (nonatomic, readwrite, copy) NSDictionary *meta;
@property (nonatomic, readwrite, copy) NSMutableDictionary *configurationDictionary;

@end

@interface MSActiveConfigConfigurationState (MSActiveConfigMutableConfigurationState) <NSMutableCopying>

/**
 You can call this method on a non-mutable instance to get a copy that you can modify.
 */
+ (MSActiveConfigMutableConfigurationState *)mutableCopyWithZone:(NSZone *)zone;

@end