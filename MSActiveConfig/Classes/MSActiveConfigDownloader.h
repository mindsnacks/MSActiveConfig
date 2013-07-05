//
//  MSActiveConfigDownloader.h
//  MSActiveConfig
//
//  Created by Javier Soto on 8/9/12.
//
//

#import <Foundation/Foundation.h>

@protocol MSActiveConfigDownloader <NSObject>

/**
 * @discussion the method must run synchronously and return the configuration dictionary.
 * @param userID (optional) if the userID is nil, the generic config is requested.
 * @param &error (optional) if set, this method should provide an error object if the download fails.
 * @return it can return nil if the request fails.
 */
- (NSDictionary *)requestActiveConfigForUserWithID:(NSString *)userID
                                             error:(NSError **)error;

@end
