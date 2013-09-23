//
//  MSActiveConfig_BaseTest.h
//  MSActiveConfig
//
//  Created by Javier Soto on 8/13/12.
//
//

#import <SenTestingKit/SenTestingKit.h>

#import <OCMock/OCMock.h>

@class MSActiveConfigMutableConfigurationState;

@interface MSActiveConfig_BaseTest : SenTestCase

- (MSActiveConfigMutableConfigurationState *)configStateWithConfigDictionary:(NSDictionary *)dictionary;

@end

extern void MSClearAllNSUserDefaults(void);

#define _MSTestWaitDuration (0.1)
#define MSTestWaitUntilTrue(expr) \
    while ((!expr)) [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:_MSTestWaitDuration]];