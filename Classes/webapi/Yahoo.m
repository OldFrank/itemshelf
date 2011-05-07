// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "DataModel.h"
#import "URLComponent.h"
#import "WebApi.h"
#import "Yahoo.h"
#import "dom.h"

///////////////////////////////////////////////////////////////////////////////////////////////
// Yahoo shopping api
	
@implementation YahooApi

- (id)init
{
    self = [super init];
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

/////////////////////////////////////////////////////////////////////////////////////
// カテゴリ

- (NSArray *)categoryStrings
{
    return [NSArray arrayWithObjects:@"All", nil];
}

/**
   Get default category (should be override)
*/
- (int)defaultCategoryIndex
{
    return 0; // all
}

/////////////////////////////////////////////////////////////////////////////////////
// 検索処理

/**
   Execute item search

   @note you must set searchKey/searchKeyType property before call this.
   And you can set searchIndex.
*/
- (void)itemSearch
{
    NSString *baseURI = @"http://itemshelf.com/cgi-bin/yahoojp.cgi?";
    URLComponent *comp = [[[URLComponent alloc] initWithURLString:baseURI] autorelease];

    NSString *param = nil;

    if (searchKeyType == SearchKeyCode) {
        // バーコード検索
        param = @"jan";
    } else {
        // キーワード検索
        param = @"keyword";
    }
    [comp setQuery:param value:searchKey];

    [comp log];
    
    NSURL *url = [comp url];
    [super sendHttpRequest:url];
}

/////////////////////////////////////////////////////////////////////////////////////
// HttpClientDelegate

/**
   @name HttpClientDelegate
*/
//@{

- (void)httpClientDidFinish:(HttpClient*)client
{
    [super httpClientDidFinish:client];

    // Parse XML
    DomParser *domParser = [[[DomParser alloc] init] autorelease];
    XmlNode *root = [domParser parse:client.receivedData];
    //[root dump];

    if (!root) {
        // XML error
        [delegate webApiDidFailed:self reason:WEBAPI_ERROR_BADREPLY message:nil];
        return;
    }

    NSMutableArray *itemArray = [[[NSMutableArray alloc] init] autorelease];
    XmlNode *hit;
    for (hit = [root findNode:@"Hit"]; hit; hit = [hit findSibling]) {
        NSString *hitIndex = [hit.attributes objectForKey:@"index"];
        if (hitIndex == nil || [hitIndex isEqualToString:@"0"]) {
            continue;
        }

        Item *item = [[Item alloc] init];
        [itemArray addObject:item];
        [item release];

        item.serviceId = serviceId;
        item.category = @"Other"; // とりあえず

        XmlNode *n;
        n = [hit findNode:@"IsbnCode"];
        if (n) {
            item.idString = n.text;
        } else {
            n = [hit findNode:@"JanCode"];
            if (n) item.idString = [NSString stringWithString:n.text];
        }
    
        item.name = [hit findNode:@"Name"].text;
        item.detailURL = [hit findNode:@"Url"].text;
        item.imageURL = [hit findNode:@"Medium"].text;
        n = [hit findNode:@"Price"];
        if (n) {
            double price = [n.text doubleValue];
            item.price = [Common currencyString:price withLocaleString:@"ja_JP"];
        }
    }

    if (itemArray.count > 0) {
        // success
        [delegate webApiDidFinish:self items:itemArray];
    } else {
        // no data
        NSString *message = @"No items";
        [delegate webApiDidFailed:self reason:WEBAPI_ERROR_NOTFOUND message:message]; //###
    }
}

//@}

@end
