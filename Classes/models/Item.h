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
