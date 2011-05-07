// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// アイテム一覧モデル
//   ItemListViewController で使用

#import <UIKit/UIKit.h>
#import "Common.h"
#import "Shelf.h"
#import "Item.h"
#import "StringArray.h"

/**
   Item list model, used from ItemListViewController

   This model contains array of items, "filtered" with
   search string and category.
*/
@interface ItemListModel : NSObject
{
    Shelf *mShelf;		///< Shelf
	
    NSString *mFilter;		///< Filter string (if nil, no filter)
    NSString *mSearchText;	///< Search string

    NSMutableArray *mFilteredList; ///< Filtered array of items.
}

@property(nonatomic,readonly) Shelf *shelf;
@property(nonatomic,retain) NSString *filter;

- (id)initWithShelf:(Shelf *)shelf;
- (int)count;
- (Item *)itemAtIndex:(int)index;
- (void)setSearchText:(NSString *)t;
- (void)setFilter:(NSString *)f;
- (void)updateFilter;
- (void)removeObject:(Item *)item;
- (void)moveRowAtIndex:(int)fromIndex toIndex:(int)toIndex;
- (void)sort:(int)kind;

@end
