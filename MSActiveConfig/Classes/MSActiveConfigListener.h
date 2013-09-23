//
//  MSActiveConfigListener.h
//  MSActiveConfig
//
//  Created by Javier Soto on 4/8/13.
//
//

#import <Foundation/Foundation.h>

@class MSActiveConfig;
@class MSActiveConfigSection;

/**
 `MSActiveConfigListener` is the protocol objects must conform to to get delegate calls when there's any change in the
 values of the `MSActiveConfigSection` they're interested in.
 */

@protocol MSActiveConfigListener <NSObject>

/**
 Refer to the `MSActiveConfigSection` documentation on how to retrieve the values for the settings.
 @note This will be called immediately after registering using the `-registerListener:forSectionName:` API 
 with the most recent settings, so that listeners don't need to persist those themselves.
 @note Dispatched on the main queue by default.
 */
- (void)activeConfig:(MSActiveConfig *)activeConfig
didReceiveConfigSection:(MSActiveConfigSection *)configSection
        forSectionName:(NSString *)sectionName;

@end