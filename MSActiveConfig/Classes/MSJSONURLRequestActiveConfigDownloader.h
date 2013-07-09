//
//  MSJSONURLRequestActiveConfigDownloader.h
//  MSActiveConfig
//
//  Created by Javier Soto on 7/5/13.
//  Copyright (c) 2013 MindSnacks. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MSActiveConfigDownloader.h"

typedef NSURLRequest *(^MSJSONURLRequestActiveConfigDownloaderCreateRequestBlock)(NSString *userID);

/**
 Convenience concrete `MSActiveConfigDownloader` implementation that expects a text/JSON response from the
 provided request and parses it returning the dictionary.
 */

@interface MSJSONURLRequestActiveConfigDownloader : NSObject <MSActiveConfigDownloader>

/**
 Designated initializer. This is all you need to use to create a `MSJSONURLRequestActiveConfigDownloader`.
 @param createRequestBlock (required) Provide a block that returns an `NSURLRequest` object taking the `userID` for which to request the configuration.
 */
- (id)initWithCreateRequestBlock:(MSJSONURLRequestActiveConfigDownloaderCreateRequestBlock)createRequestBlock;

@end
