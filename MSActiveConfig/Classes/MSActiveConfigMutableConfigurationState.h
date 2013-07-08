//
//  MSActiveConfigMutableConfigurationState.h
//  MSActiveConfig
//
//  Created by Javier Soto on 5/14/13.
//
//

#import "MSActiveConfigConfigurationState.h"

@interface MSActiveConfigMutableConfigurationState : MSActiveConfigConfigurationState

@property (nonatomic, readwrite, copy) NSString *creationDateString;
@property (nonatomic, readwrite, copy) NSString *formatVersion;
@property (nonatomic, readwrite, copy) NSDictionary *meta;
@property (nonatomic, readwrite, copy) NSMutableDictionary *configurationDictionary;

@end

@interface MSActiveConfigConfigurationState (MSActiveConfigMutableConfigurationState) <NSMutableCopying>

+ (MSActiveConfigMutableConfigurationState *)mutableCopyWithZone:(NSZone *)zone;

@end