// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// データモデル

#import <UIKit/UIKit.h>
#import "Common.h"
#import "Item.h"
#import "Shelf.h"

//#define MAX_ITEM_COUNT_FOR_LITE_EDITION	100

/**
   Main data model of itemshelf, contains all shelves, items.
   
*/
@interface DataModel : NSObject
{
    NSMutableArray *mShelves;	///< All shelves

//    NSString *currentCountry;	///< Current country setting
//    NSArray *countries;		///< Countries array
}

@property(nonatomic,retain) NSMutableArray *shelves;

+ (DataModel*)sharedDataModel;
+ (void)finalize;

- (void)loadDB;

- (Shelf *)shelf:(int)shelfId;
- (Shelf *)shelfAtIndex:(int)index;
- (int)shelvesCount;
- (void)addShelf:(Shelf *)shelf;
- (void)removeShelf:(Shelf *)shelf;
- (void)reorderShelf:(int)from to:(int)to;
- (NSMutableArray *)normalShelves;
- (void)updateSmartShelves;

- (int)_allItemCount;
- (BOOL)addItem:(Item *)item;
- (void)removeItem:(Item *)item;
- (void)changeShelf:(Item *)item withShelf:(int)shelf;
- (Item *)findSameItem:(Item*)item;
- (void)alertItemCountOver;

- (NSMutableArray*)filterArray:(Shelf *)shelf;
- (NSMutableArray *)allTags;

@end
