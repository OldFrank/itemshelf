// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
  ItemShelf for iPhone/iPod touch

  Copyright (c) 2008, ItemShelf Development Team. All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer. 

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution. 

  3. Neither the name of the project nor the names of its contributors
  may be used to endorse or promote products derived from this software
  without specific prior written permission. 

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "DataModel.h"
#import "URLComponent.h"
#import "WebApi.h"
#import "Yahoo.h"

///////////////////////////////////////////////////////////////////////////////////////////////
// Yahoo shopping api
	
@implementation YahooApi

- (id)init
{
    self = [super init];
    if (self) {
        itemArray = [[NSMutableArray alloc] initWithCapacity:10];
        curString = [[NSMutableString alloc] initWithCapacity:20];
        responseData = [[NSMutableData alloc] initWithCapacity:256];
    }
    return self;
}

- (void)dealloc
{
    [responseData release];
    [itemArray release];
    [curString release];

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
    [itemArray removeAllObjects];
    [responseData setLength:0];

    NSString *baseURI = @"http://itemshelf.com/cgi-bin/yahoojp.cgi?";
    URLComponent *comp = [[[URLComponent alloc] initWithURLString:baseURI] autorelease];

    NSString *operation = nil;
    NSString *param = nil;

    if (searchKeyType == SearchKeyCode) {
        // バーコード検索
        param = @"jan";
    } else {
        // キーワード検索
        param = @"query";
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

    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:client.receivedData];
	
    itemCounter = -1;
	
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:YES];
    BOOL result = [parser parse];
    [parser release];
	
    if (delegate) {
        if (!result) {
            // XML error
            [delegate webApiDidFailed:self reason:WEBAPI_ERROR_BADREPLY message:nil];
        } else if (itemArray.count > 0) {
            // success
            [delegate webApiDidFinish:self items:itemArray];
        } else {
            // no data
            [delegate webApiDidFailed:self reason:WEBAPI_ERROR_NOTFOUND message:@"No items"]; //###
        }
    }
}

//@}

/////////////////////////////////////////////////////////////////////////////////////
// パーサ delegate

/**
   @name NXSMLParser delegate
*/
//@{

// 開始タグの処理
- (void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elem namespaceURI:(NSString *)nspace qualifiedName:(NSString *)qname attributes:(NSDictionary *)attributes
{
    [curString setString:@""];
	
    if ([elem isEqualToString:@"Hit"]) {
        // check index attriute
        NSString *hitIndex = [attributes objectForKey:@"index"];
        if (hitIndex != nil && ![hitIndex isEqualToString:@"0"]) {
            itemCounter++;

            Item *item = [[Item alloc] init];

            item.serviceId = serviceId;
            item.category = @"Other"; // とりあえず

            [itemArray addObject:item];
            [item release];
        }
    }
}

// 文字列処理
- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string
{
    [curString appendString:string];
}

// 終了タグの処理
- (void)parser:(NSXMLParser*)parser didEndElement:(NSString*)elem namespaceURI:(NSString *)nspace qualifiedName:(NSString *)qname
{
    LOG(@"%@ = %@", elem, curString);

    if (itemCounter < 0) {
        [curString setString:@""];
        return;
    }
    Item *item = [itemArray objectAtIndex:itemCounter];

    if ([elem isEqualToString:@"IsbnCode"]) {
        item.idString = [NSString stringWithString:curString];
    }
    else if ([elem isEqualToString:@"JanCode"]) {
        if (item.idString == nil) {
            item.idString = [NSString stringWithString:curString];
        }
    }
    else if ([elem isEqualToString:@"Name"]) {
        item.name = [NSString stringWithString:curString];
    }
    else if ([elem isEqualToString:@"Url"]) {
        item.detailURL = [NSString stringWithString:curString];
    }
    else if ([elem isEqualToString:@"Medium"]) {
        item.imageURL = [NSString stringWithString:curString];
    }
    else if ([elem isEqualToString:@"Price"]) {
        double price = [[NSString stringWithString:curString] doubleValue];
        item.price = [Common currencyString:price withLocaleString:@"ja_JP"];
    }

    // カテゴリはどうするか？

    [curString setString:@""];
}

//@}

@end
