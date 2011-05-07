// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
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
