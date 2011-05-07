// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// 棚クラス

#import "Item.h"
#import "Shelf.h"

@implementation Shelf

@synthesize array = mArray;

- (id)init
{
    self = [super init];
    if (self) {
        self.array = [[[NSMutableArray alloc] initWithCapacity:30] autorelease];

        self.name = nil;
        self.shelfType = ShelfTypeNormal;
        self.titleFilter = @"";
        self.authorFilter = @"";
        self.manufacturerFilter = @"";
        self.tagsFilter = @"";
        self.starFilter = 0;
    }
    return self;
}

- (void)dealloc
{
    [mArray release];
    [super dealloc];
}

/**
   Add item to shelf
*/
- (void)addItem:(Item*)item
{
    [mArray addObject:item];
}

/**
   Remove item from shelf
*/
- (void)removeItem:(Item*)item
{
    [mArray removeObject:item];
}

/**
   Check if the item is contained in this shelf.

   @return Returns YES if the item is contained.
*/
- (BOOL)containsItem:(Item*)item
{
    return [mArray containsObject:item];
}

/**
   NSFastEnumeration protocol
*/
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
    return [mArray countByEnumeratingWithState:state objects:stackbuf count:len];
}

/**
   Returns count of items
*/
- (int)itemCount
{
    return mArray.count;
}
 
/**
   Used from sortBySorder (private)
*/
static int compareBySorder(Item *t1, Item *t2, void *context)
{
    if (t1.sorder == t2.sorder) {
        return [t1.date compare:t2.date];
    }
    if (t1.sorder < t2.sorder) {
        return NSOrderedAscending;
    }
    return NSOrderedDescending;
}

/**
   Sort items which sorder
*/
- (void)sortBySorder
{
    [mArray sortUsingFunction:compareBySorder context:NULL];
}

///////////////////////////////////////////////////////////////

/**
   @name Database operations
*/
//@{

//
// Database operations
//
+ (BOOL)migrate
{
    BOOL ret = [super migrate];

    if (ret) {
        // 初期データを入れる
        for (int i = 0; i < 3; i++) {
            NSString *name;
            switch (i) {
            case 0:
                name = @"Unclassified";
                break;
            case 1:
                name = @"Wishlist";
                break;
            case 2:
                name = @"ItemShelf";
                break;
            }

            Shelf *shelf = [[[Shelf alloc] init] autorelease];
            shelf.name = NSLocalizedString(name, @"");
            shelf.sorder = i;
            [shelf save];
        }
    }
    return ret;
}

/**
   Delete row from shelf table of the database.
*/
- (void)delete
{
    Database *db = [Database instance];
    [db beginTransaction];
    [super delete];

    // この棚にあるアイテムも全部消す
    if (self.shelfType == ShelfTypeNormal) {
        for (Item *item in mArray) {
            [item delete];
        }
    }

    [db commitTransaction];
}

//@}

@end
