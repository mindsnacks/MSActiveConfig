//
//  MSActiveConfigMutableConfigurationState.m
//  MSActiveConfig
//
//  Created by Javier Soto on 5/14/13.
//
//

#import "MSActiveConfigMutableConfigurationState.h"

@implementation MSActiveConfigMutableConfigurationState

@synthesize configurationDictionary = _configurationDictionary;

- (id)copyWithZone:(NSZone *)zone
{
    MSActiveConfigMutableConfigurationState *nonMutableConfigStateCopy = [[[MSActiveConfigConfigurationState class] allocWithZone:zone] init];

    nonMutableConfigStateCopy.configurationDictionary = self.configurationDictionary;
    nonMutableConfigStateCopy.formatVersion = self.formatVersion;
    nonMutableConfigStateCopy.meta = self.meta;
    nonMutableConfigStateCopy.creationDateString = self.creationDateString;
    
    return nonMutableConfigStateCopy;
}

- (void)setConfigurationDictionary:(NSMutableDictionary *)configurationDictionary
{
    if (configurationDictionary != _configurationDictionary)
    {
        _configurationDictionary = [configurationDictionary mutableCopy];
    }
}

@end

@implementation MSActiveConfigConfigurationState (MSActiveConfigMutableConfigurationState)

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone
{
    MSActiveConfigMutableConfigurationState *mutableCopy = [[MSActiveConfigMutableConfigurationState allocWithZone:zone] init];

    mutableCopy.configurationDictionary = [self.configurationDictionary mutableCopy];
    mutableCopy.formatVersion = self.formatVersion;
    mutableCopy.meta = self.meta;
    mutableCopy.creationDateString = self.creationDateString;

    return mutableCopy;
}

- (MSActiveConfigMutableConfigurationState *)mutableCopy
{
    return [self mutableCopyWithZone:nil];
}

@end