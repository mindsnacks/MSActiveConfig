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
 * @discussion convenience concrete `MSActiveConfigDownloader` that expects a text/JSON response and parses it returning the dictionary.
 */
@interface MSJSONURLRequestActiveConfigDownloader : NSObject <MSActiveConfigDownloader>

/**
 * @param createRequestBlock (required) provide a block that returns an `NSURLRequest` object taking the userID for which to request the configuration.
 */
- (id)initWithCreateRequestBlock:(MSJSONURLRequestActiveConfigDownloaderCreateRequestBlock)createRequestBlock;

@end
