//
//  MSJSONURLRequestActiveConfigDownloader.m
//  MSActiveConfig
//
//  Created by Javier Soto on 7/5/13.
//  Copyright (c) 2013 MindSnacks. All rights reserved.
//

#import "MSJSONURLRequestActiveConfigDownloader.h"

@interface MSJSONURLRequestActiveConfigDownloader ()

@property (nonatomic, copy) MSJSONURLRequestActiveConfigDownloaderCreateRequestBlock createRequestBlock;

@end

@implementation MSJSONURLRequestActiveConfigDownloader

- (id)initWithCreateRequestBlock:(MSJSONURLRequestActiveConfigDownloaderCreateRequestBlock)createRequestBlock
{
    NSParameterAssert(createRequestBlock);

    if ((self = [super init]))
    {
        self.createRequestBlock = createRequestBlock;
    }

    return self;
}

- (id)init
{
    return [self initWithCreateRequestBlock:nil];
}

- (NSDictionary *)requestActiveConfigForUserWithID:(NSString *)userID error:(NSError *__autoreleasing *)error
{
    NSURLRequest *request = self.createRequestBlock(userID);

    NSParameterAssert(request);

    NSURLResponse *response = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];

    if (*error)
    {
        return nil;
    }
    else
    {
        return [NSJSONSerialization JSONObjectWithData:responseData options:0 error:error];
    }
}

@end
