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

// 棚クラス

#import "Item.h"
#import "Shelf.h"

@implementation Shelf
@synthesize array;

- (id)init
{
    self = [super init];
    if (self) {
        self.array = [[NSMutableArray alloc] initWithCapacity:30];

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
    [mDb beginTransaction];
    [super delete];

    // この棚にあるアイテムも全部消す
    if (mShelfType == ShelfTypeNormal) {
        for (Item *item in mArray) {
            [item delete];
        }
    }

    [mDb commitTransaction];
}

//@}

@end
