// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// Kakaku.com API (Japan)

#import <UIKit/UIKit.h>
#import "Common.h"
#import "Item.h"
#import "WebApi.h"

/**
   Kakaku com API

   To search items, create the instance of KakakuComApi,
   set delegate, set searchTitle then call itemSearch.

   Note: search with keyword (barcode) is not supported!

   The result will be passed with WebApiDelegate protocol.
*/
@interface KakakuComApi : WebApi {
}

- (void)itemSearch;

@end
