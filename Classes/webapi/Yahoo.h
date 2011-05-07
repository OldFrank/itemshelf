// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// Yahoo shopping API (Japan)

#import <UIKit/UIKit.h>
#import "Common.h"
#import "Item.h"
#import "WebApi.h"

@interface YahooApi : WebApi {
}

- (void)itemSearch;

@end
