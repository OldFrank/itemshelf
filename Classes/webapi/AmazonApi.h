// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */
// Amazon API

#import <UIKit/UIKit.h>
#import "Common.h"
#import "Item.h"
#import "WebApi.h"
#import "URLComponent.h"

@class AmazonXmlState;

#define AMAZON_MAX_SEARCH_ITEMS 25

/**
   Amazon API

   To search items at Amazon, create the instance of AmazonApi,
   set delegate, set searchKey/searchKeyType (optionally searchIndex),
   then call itemSearch.

   The result will be passed with AmazonApiDelegate protocol.
*/
@interface AmazonApi : WebApi {
    NSString *baseURI;		///< base URI to call amazon API
}

+ (NSString *)detailUrl:(Item *)item isMobile:(BOOL)isMobile;

- (void)itemSearch;
//- (void)setCountry:(NSString*)country;

@end
