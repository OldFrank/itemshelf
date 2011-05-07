// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "HttpClient.h"

@implementation HttpClient

@synthesize receivedData;

- (id)init:(id<HttpClientDelegate>)d
{
    self = [super init];
    if (self) {
        delegate = d;
        receivedData = [[NSMutableData alloc] init];
        connection = nil;
    }
    return self;
}

- (void)dealloc
{
    [connection release];
    [receivedData release];
    [super dealloc];
}

- (void)requestGet:(NSURL *)url
{
    [self retain];

    [receivedData setLength:0];
    [connection release];

    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url];
    connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    [req release];
}

- (void)cancel
{
    [connection cancel];
    [self autorelease];
}

// NSURLConnection delegates

- (void)connection:(NSURLConnection*)conn didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn
{
    [delegate httpClientDidFinish:self];
    [self autorelease];
}

- (void)connection:(NSURLConnection*)conn didFailWithError:(NSError*)err
{
    [delegate httpClientDidFailed:self error:err];
    [self autorelease];
}

@end
