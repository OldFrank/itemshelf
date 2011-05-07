// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// Web API

#define ENABLE_KAKAKUCOM   0
#define ENABLE_RAKUTEN     1

#import <UIKit/UIKit.h>
#import "Common.h"
#import "Item.h"
#import "HttpClient.h"

@class WebApi;

// error codes
#define WEBAPI_ERROR_NETWORK	0
#define WEBAPI_ERROR_NOTFOUND	1
#define WEBAPI_ERROR_BADREPLY   2
#define WEBAPI_ERROR_BADPARAM   3

// service ids
enum {
    AmazonUS = 0,
    AmazonCA,
    AmazonUK,
    AmazonFR,
    AmazonDE,
    AmazonJP,
#if ENABLE_RAKUTEN
    Rakuten,
#endif
    Yahoo,
#if ENABLE_KAKAKUCOM
    KakakuCom,
#endif

    MaxServiceId
};

// search key types
typedef enum {
    SearchKeyCode = 0,
    SearchKeyTitle,
    SearchKeyAuthor,
    SearchKeyArtist,
    SearchKeyAll
} SearchKeyType;

/**
   Web API delegate protocol
*/
@protocol WebApiDelegate
/**
   Called when web API is successfully finished

   @param[in] webApi webApi instance
   @param[in] items Found items array
*/
-(void)webApiDidFinish:(WebApi*)webApi items:(NSMutableArray*)items;

/**
   Called when web API is failed.

   @param[in] webApi WebApi instance
   @param[in] reason Reason code
   @param[in] message Error message
*/
-(void)webApiDidFailed:(WebApi*)amazonApi reason:(int)reason message:(NSString *)message;
@end

/** 
   Web API factory
*/
@interface WebApiFactory : NSObject {
    int serviceId;
    BOOL isCodeSearch;
}

@property(nonatomic, assign) int serviceId;

+ (WebApiFactory *)webApiFactory;
- (void)setCodeSearch;
- (void)loadDefaults;
- (void)saveDefaults;
- (int)_fallbackServiceId;
- (int)serviceIdFromCountryCode:(NSString*)country;
- (WebApi*)allocWebApi;
- (NSArray*)serviceIdStrings;
- (NSString*)serviceIdString;

+ (NSString *)detailUrl:(Item *)item isMobile:(BOOL)isMobile;

@end

/**
   Web API

   Base class of web api (amazon, kakaku.com etc.)

   To search items, create the instance of derived class of WebApi.
   set delegate, set parameters, then call itemSearch.

   The result will be passed with webApiDelegate protocol.
*/
@interface WebApi : NSObject <HttpClientDelegate> {
    id<WebApiDelegate> delegate;

    int serviceId;      	///< serviceId

    NSString *searchKey;        ///< Key for search (barcode / title / any keyword)
    SearchKeyType searchKeyType;  
    NSString *searchIndex;      ///< Search index (category)
}

@property(nonatomic, assign) id<WebApiDelegate> delegate;
@property(nonatomic, retain) NSString *searchKey;
@property(nonatomic, assign) SearchKeyType searchKeyType;
@property(nonatomic, retain) NSString *searchIndex;

- (void)itemSearch;
- (void)setServiceId:(int)sid;

- (NSArray *)categoryStrings;
- (int)defaultCategoryIndex;

// used by derived class
- (void)sendHttpRequest:(NSURL*)url;

@end
