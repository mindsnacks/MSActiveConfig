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

@protocol MSActiveConfigListener <NSObject>

/**
 * @discussion callback an active config listener gets whenever there's an update of the settings they're interested in (`key`)
 * Note: This will be called after registering with the most recent settings, so that listeners don't need to persist those themselves.
 * @note Dispatched on the main queue.
 */
- (void)activeConfig:(MSActiveConfig *)activeConfig
didReceiveConfigSection:(MSActiveConfigSection *)configSection
        forSectionName:(NSString *)sectionName;

@end