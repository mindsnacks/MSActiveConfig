//
//  MSActiveConfig_BaseTest.m
//  MSActiveConfig
//
//  Created by Javier Soto on 8/13/12.
//
//

#import "MSActiveConfig_BaseTest.h"

#import "MSActiveConfigMutableConfigurationState.h"

@implementation MSActiveConfig_BaseTest

- (MSActiveConfigMutableConfigurationState *)configStateWithConfigDictionary:(NSDictionary *)dictionary
{
    NSDictionary *configDictionary = @{
        @"meta" : @{
            @"format_version_string" : @"1.0",
            @"creation_time" : @"2012-08-13T19:36Z",
        },
        @"config_sections" : dictionary
    };

    return [[MSActiveConfigMutableConfigurationState alloc] initWithDictionary:configDictionary];
}

@end

void MSClearAllNSUserDefaults(void)
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    for (NSString *key in [userDefaults dictionaryRepresentation].allKeys)
    {
        [userDefaults removeObjectForKey:key];
    }

    [userDefaults synchronize];
}
