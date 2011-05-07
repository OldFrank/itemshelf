// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AmazonApi.h"
#import "DataModel.h"
#import "URLComponent.h"
#import "WebApi.h"
#import "KakakuCom.h"
#import "dom.h"

///////////////////////////////////////////////////////////////////////////////////////////////
// KakakuCom API
	
@implementation KakakuComApi

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
// 検索処理

/**
   Execute item search

   @note you must set searchKey / searchKeyType property before call this.
   And you can set searchIndex.
*/
- (void)itemSearch
{
    if (searchKeyType == SearchKeyCode) {
        // バーコード検索は対応しない
        if (delegate) {
            [delegate webApiDidFailed:self reason:WEBAPI_ERROR_BADPARAM
                      message:@"価格.com はバーコード検索に対応していません"];
        }
        return;
    }

    NSString *baseURI = @"http://itemshelf.com/cgi-bin/kakakucomsearch.cgi";
    URLComponent *comp = [[[URLComponent alloc] initWithURLString:baseURI] autorelease];

    // すべてキーワード検索
    [comp setQuery:@"keyword" value:searchKey];
    [comp log];
    
    // カテゴリ指定はしない、オーダは固定
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
    XmlNode *itemNode;
    for (itemNode = [root findNode:@"Item"]; itemNode; itemNode = [itemNode findSibling]) {
        Item *item = [[Item alloc] init];
        [itemArray addObject:item];
        [item release];

        item.serviceId = serviceId;
        item.category = @"Other"; // とりあえず

        item.idString = [itemNode findNode:@"ProductID"].text;
        item.name = [itemNode findNode:@"ProductName"].text;
        //item.author = [itemNode findNode:@"author"].text;
        item.manufacturer = [itemNode findNode:@"MakerName"].text;
        item.detailURL = [itemNode findNode:@"ItemPageUrl"].text;
        item.imageURL = [itemNode findNode:@"ImageUrl"].text;
        item.price = [itemNode findNode:@"LowestPrice"].text;
    }

    if (itemArray.count > 0) {
        // success
        [delegate webApiDidFinish:self items:itemArray];
    } else {
        // no data
        NSString *message = nil;
        XmlNode *err = [root findNode:@"Error"];
        if (err) {
            message = [err findNode:@"Message"].text;
        }
        if (message == nil) {
            message = @"No items";
        }
        [delegate webApiDidFailed:self reason:WEBAPI_ERROR_NOTFOUND message:message]; //###
    }
}

//@}

@end
