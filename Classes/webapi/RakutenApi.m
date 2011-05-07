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
#import "RakutenApi.h"
#import "dom.h"

///////////////////////////////////////////////////////////////////////////////////////////////
// Rakuten API
	
@implementation RakutenApi

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
    return [NSArray arrayWithObjects:@"All", @"Books", @"DVD", @"Music", @"Game", @"Software", nil];
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
#if 0
    if (searchKeyType == SearchKeyCode) {
        // バーコード検索は対応しない
        if (delegate) {
            [delegate webApiDidFailed:self reason:WEBAPI_ERROR_BADPARAM
                      message:@"楽天はバーコード検索に対応していません"];
        }
        return;
    }
#endif
	
    //NSString *baseURI = @"http://itemshelf.com/cgi-bin/rakutensearch.cgi?";
    NSString *baseURI = @"http://itemshelf.com/cgi-bin/rakutensearch2.cgi?";
    URLComponent *comp = [[[URLComponent alloc] initWithURLString:baseURI] autorelease];

    NSString *operation = nil;
    NSString *param = nil;

    if (searchKeyType == SearchKeyCode) {
        // バーコード検索
        // ここでは書籍のみを検索する (カテゴリが不明なので
        operation = @"BooksBookSearch";
        param = @"isbn";
    } else {
        // キーワード検索

        // カテゴリ別に operation を決定
        if ([searchIndex isEqualToString:@"Books"]) {
            operation = @"BooksBookSearch";
        }
        else if ([searchIndex isEqualToString:@"DVD"]) {
            operation = @"BooksDVDSearch";
        }
        else if ([searchIndex isEqualToString:@"Music"]) {
            operation = @"BooksCDSearch";
        }
        else if ([searchIndex isEqualToString:@"Game"]) {
            operation = @"BooksGameSearch";
        }
        else if ([searchIndex isEqualToString:@"Software"]) {
            operation = @"BooksSoftwareSearch";
        } else {
            operation = @"BooksTotalSearch";
            param = @"keyword"; // keyword 固定
        }

        // パラメータを設定
        if (param == nil) {
            switch (searchKeyType) {
            case SearchKeyAuthor:
            case SearchKeyArtist:
                if ([searchIndex isEqualToString:@"CD"] ||
                    [searchIndex isEqualToString:@"DVD"]) {
                    param = @"artistName";
                } else {
                    param = @"author";
                }
                break;

            case SearchKeyAll:
            case SearchKeyTitle:
            default:
                param = @"title";
                break;
            }
        }
    }
    [comp setQuery:@"operation" value:operation];
    [comp setQuery:param value:searchKey];

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

        XmlNode *n;
        n = [itemNode findNode:@"isbn"];
        if (n) {
            item.idString = n.text;
        } else {
            n = [itemNode findNode:@"jan"];
            if (n) item.idString = n.text;
        }
    
        item.name = [itemNode findNode:@"title"].text;
        item.author = [itemNode findNode:@"author"].text;
        if (item.author == nil) {
            item.author = [itemNode findNode:@"artistName"].text;
        }
        item.manufacturer = [itemNode findNode:@"publisherName"].text;
        if (item.manufacturer == nil) {
            item.manufacturer = [itemNode findNode:@"label"].text;
        }
        item.detailURL = [itemNode findNode:@"itemUrl"].text;
        item.imageURL = [itemNode findNode:@"mediumImageUrl"].text;
        n = [itemNode findNode:@"itemPrice"];
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
        NSString *message = [root findNode:@"Status"].text;
        if (message == nil) {
            message = @"No items";
        }
        [delegate webApiDidFailed:self reason:WEBAPI_ERROR_NOTFOUND message:message]; //###
    }
}

//@}

@end
