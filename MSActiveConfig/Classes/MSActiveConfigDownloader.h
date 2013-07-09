//
//  MSActiveConfigDownloader.h
//  MSActiveConfig
//
//  Created by Javier Soto on 8/9/12.
//
//

#import <Foundation/Foundation.h>

/**
 An object must conform to the `MSActiveConfigDownloader` protocol for `MSActiveConfig` to be able to ask it to download
 a configuration update from the network.
 */

@protocol MSActiveConfigDownloader <NSObject>

/**
 This method must run synchronously and return when the request is finished.
 @note This method is invoked on an arbitrary thread.
 @param userID (optional) If the userID is `nil`, it should request a generic (not user-specific) configuration.
 @param error (optional) This method should provide an error object if the download fails.
 @return The retrieved configuration dictionary or `nil` if the request failed.
 */
- (NSDictionary *)requestActiveConfigForUserWithID:(NSString *)userID
                                             error:(NSError **)error;

@end
