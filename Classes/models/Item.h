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

// アイテム情報を格納するクラス

#import <UIKit/UIKit.h>
//#import "Common.h"
//#import "Database.h"
#import "ItemBase.h"

// 画像をメモリにキャッシュしておく個数
#define MAX_IMAGE_CACHE_AGE		70

@class Item;

@protocol ItemDelegate
- (void)itemDidFinishDownloadImage:(Item*)item;
@end

// Item 情報
@interface Item : ItemBase
{
/*
    NSDate *date;	///< Registered date
    int shelfId;	///< Shelf ID (SHELF_*)

    int serviceId;	///< serviceId (same as service ID of WebApi) (old: idType)
    NSString *idString;	///< ID string (Barcode or other uniq item ID of each service)
    NSString *asin;	///< ASIN: Amazon Standard Identification Number

    NSString *name;	///< Item name
    NSString *author;	///< Author
    NSString *manufacturer;	///< Manufacturer name
    NSString *category;	///< Category (old:productGroup)
    NSString *detailURL;	///< URL of detail page of the item
    NSString *price;	///< Price info
    NSString *tags;	///< Tag info (reserved)

    NSString *memo;	///< User defined memo (reserved)
    NSString *imageURL;	///< URL of image
	
    int sorder;		///< Sort order
    int star;           ///< Star
*/

    UIImage *mImageCache; ///< Image cache
	
    // image download 用
    NSMutableData *mBuffer;  ///< Temporary buffer to download image
    id<ItemDelegate> mItemDelegate; ///< Delegate of ItemDelegate protocol

    // ItemView 用
    //NSMutableArray *infoStrings; ///< Information strings, used with ItemView
    BOOL mRegisteredWithShelf;  ///< Is registered in shelf?
}

@property(nonatomic,retain) UIImage *imageCache;

//@property(nonatomic,retain) NSMutableArray *infoStrings;
@property(nonatomic,assign) BOOL registeredWithShelf;

- (BOOL)isEqualToItem:(Item*)item;
- (void)updateWithNewItem:(Item*)item;
- (void)delete;
- (void)changeShelf:(int)shelf;

+ (void)clearAllImageCache;
- (UIImage *)getImage:(id<ItemDelegate>)delegate;
- (void)saveImageCache:(UIImage *)image data:(NSData *)data;
- (void)cancelDownload;
- (UIImage*)_getNoImage;
- (void)_refreshImageCache;
- (void)_putImageCache;
- (NSString *)_imagePath; // private
- (void)_fixImagePath;
- (void)_deleteImageFile;
+ (void)deleteAllImageCache;

- (int)numberOfAdditionalInfo;
- (NSString *)additionalInfoKeyAtIndex:(int)idx;
- (NSString *)additionalInfoValueAtIndex:(int)idx;
- (BOOL)isAdditionalInfoEditableAtIndex:(int)idx;
- (void)setAdditionalInfoValueAtIndex:(int)idx withValue:(NSString *)value;

@end
