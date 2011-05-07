// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// 棚クラス

#import <UIKit/UIKit.h>
#import "Common.h"
#import "Database.h"
#import "ShelfBase.h"

/**
   Shelf type
*/
#define ShelfTypeNormal 0  ///< Normal shelf
#define ShelfTypeSmart  1  ///< Smart shelf

#define SHELF_ALL_PKEY	-99999	///< Special primary key for "All shelf".

@class Item;

/**
   Shelf class
*/
@interface Shelf : ShelfBase <NSFastEnumeration>
{
    NSMutableArray *mArray;	///< Array of items.
}

@property(nonatomic,retain) NSMutableArray *array;

- (void)addItem:(Item*)item;
- (void)removeItem:(Item*)item;
- (BOOL)containsItem:(Item*)item;
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len;
- (int)itemCount;

- (void)sortBySorder;

//+ (void)checkTable;
//- (void)loadRow:(dbstmt *)stmt;
//- (void)_insert;
- (void)delete;
//- (void)updateName;
//- (void)updateSorder;
//- (void)updateSmartFilters;
@end

/**
   Smart shelf
*/
@interface Shelf(SmartShelf)
- (void)updateSmartShelf:(NSMutableArray *)shelves;

// private
- (NSMutableArray *)_makeFilterStrings:(NSString *)filter;
- (BOOL)_isMatchSmartShelf:(Item *)item;
- (BOOL)_isMatchSmartFilter:(NSMutableArray *)filterStrings value:(NSString*)value;
@end
