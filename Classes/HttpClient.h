// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>

@class HttpClient;

@protocol HttpClientDelegate
- (void)httpClientDidFinish:(HttpClient*)client;
- (void)httpClientDidFailed:(HttpClient*)client error:(NSError*)err;
@end

@interface HttpClient : NSObject {
    id<HttpClientDelegate> delegate;

    NSURLConnection *connection;
    NSMutableData *receivedData;
}

@property(nonatomic,readonly) NSMutableData *receivedData;

- (id)init:(id<HttpClientDelegate>)d;
- (void)requestGet:(NSURL *)url;
- (void)cancel;

@end
