
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

#import "ItemListModel.h"
#import "DataModel.h"

@implementation ItemListModel

@synthesize shelf = mShelf;

/**
   Initialize the model with specified shelf

   @param[in] sh Shelf
   @return initialized instance
*/
- (id)initWithShelf:(Shelf *)sh
{
    self = [super init];

    mShelf = [sh retain];
    mSearchText = nil;
    mFilter = nil;
    mFilteredList = [[NSMutableArray alloc] initWithCapacity:50];

    [self updateFilter];

    return self;
}

- (void)dealloc {
    [mShelf release];
    [mFilteredList release];
    [mFilter release];
    [mSearchText release];
    [super dealloc];
}

/**
   Returns number of filtered items
*/
- (int)count
{
    return [mFilteredList count];
}

/**
   Get the item at index in filtered items.

   @param[in] index Index of the item.
   @note The index is reversed order.
*/
- (Item *)itemAtIndex:(int)index
{
    int n = [mFilteredList count] - 1 - index;
    if (n < 0) {
        ASSERT(NO);
        return nil;
    }
    Item *item = [mFilteredList objectAtIndex:n];
    return item;
}

/**
   Returns current filter string
*/
- (NSString*)filter
{
    return mFilter;
}

/**
   Set filter string.

   @param[in] f Filter string
*/
- (void)setFilter:(NSString *)f
{
    if (mFilter != f) {
        [mFilter release];
        mFilter = [f retain];
        [self updateFilter];
    }
}

/**
   Set search string.

   @param[in] t Search string
*/
- (void)setSearchText:(NSString *)t
{
    if (mSearchText != t) {
        [mSearchText release];
        mSearchText = [t retain];
        [self updateFilter];
    }
}

/**
   Update filtered items (private)
*/
- (void)updateFilter
{
    ASSERT(mShelf);

    [mFilteredList removeAllObjects];
	
    Item *item;
    for (item in mShelf) {
        // フィルタチェック
        if (mFilter != nil && ![item.category isEqualToString:mFilter]) {
            continue;
        }
		
        // 検索テキストチェック
        if (mSearchText != nil && mSearchText.length > 0) {
            BOOL match = NO;
            NSRange range;
			
            range = [item.name rangeOfString:mSearchText options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound) match = YES;

            range = [item.author rangeOfString:mSearchText options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound) match = YES;
			
            range = [item.manufacturer rangeOfString:mSearchText options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound) match = YES;
			
            if (!match) continue;
        }

        [mFilteredList addObject:item];
    }
}

/**
   Remove item from the model
*/
- (void)removeObject:(Item *)item
{
    [mFilteredList removeObject:item];
    [[DataModel sharedDataModel] removeItem:item];
}

/**
   Move item order

   @param[in] fromIndex Index from which the item move.
   @param[in] toIndex Index to which the item move.

   @note Item data of original shelf will be sorted too.
*/
- (void)moveRowAtIndex:(int)fromIndex toIndex:(int)toIndex
{
    // filteredList の中のインデックスを計算
    int from = [mFilteredList count] - 1 - fromIndex;
    int to   = [mFilteredList count] - 1 - toIndex;

    if (from == to) {
        return;
    }
	
    // リスト内の入れ替えを実施
    Item *item = [[mFilteredList objectAtIndex:from] retain];
    [mFilteredList removeObjectAtIndex:from];
    [mFilteredList insertObject:item atIndex:to];
    [item release];
	
    // sorder を入れ替える
    [[Database instance] beginTransaction];
    if (to < from) {
        Item *a, *b = nil;
        for (int i = to; i < from; i++) {
            a = [mFilteredList objectAtIndex:i];
            b = [mFilteredList objectAtIndex:i+1];
            int tmp = a.sorder;
            a.sorder = b.sorder;
            b.sorder = tmp;
			
            [a save];
        }
        ASSERT(b);
        [b save];
    } else {
        Item *a, *b = nil;
        for (int i = to; i > from; i--) {
            a = [mFilteredList objectAtIndex:i];
            b = [mFilteredList objectAtIndex:i-1];
            int tmp = a.sorder;
            a.sorder = b.sorder;
            b.sorder = tmp;
			
            [a save];
        }
        ASSERT(b);
        [b save];
    }
    [[Database instance] commitTransaction];
	
    // Filter されたデータだけでなく、元データをソートしておく必要がある。
    // TBD : SmartShelf の場合、元データがどこにあるのかわからないので、
    // 全部の棚をソートしなければならない。
    for (Shelf *s in [[DataModel sharedDataModel] shelves]) {
        [s sortBySorder];
    }
}

/*
	ソート用比較関数
	逆順に並べていることに注意。画面上では、上のほうが後に並んでいるデータなので。
 */
static int compByTitle(Item *a, Item *b, void *ctx)
{
    return -[a.name compare:b.name];
}
static int compByAuthor(Item *a, Item *b, void *ctx)
{
    return -[a.author compare:b.author];
}
static int compByManufacturer(Item *a, Item *b, void *ctx)
{
    return -[a.manufacturer compare:b.manufacturer];
}
static int compByStar(Item *a, Item *b, void *ctx)
{
    return a.star - b.star;
}
static int compByDate(Item *a, Item *b, void *ctx)
{
    int ret;
    switch ([a.date compare:b.date]) {
        case NSOrderedSame:
            ret = 0;
            break;
        case NSOrderedAscending:
            ret = -1;
            break;
        default:
            ret = 1;
            break;
    }
            
    return ret;
}

/**
   @brief ソート
*/
- (void)sort:(int)kind
{
    // データをソートする
    switch (kind) {
    case 0:
    default:
        [mFilteredList sortUsingFunction:compByTitle context:0];
        break;
    case 1:
        [mFilteredList sortUsingFunction:compByAuthor context:0];
        break;
    case 2:
        [mFilteredList sortUsingFunction:compByManufacturer context:0];
        break;
    case 3:
        [mFilteredList sortUsingFunction:compByStar context:0];
        break;
    case 4:
        [mFilteredList sortUsingFunction:compByDate context:0];
        break;
    }

    // sorder を取り出す
    int count = [mFilteredList count];
    NSMutableArray *sorders = [[[NSMutableArray alloc] initWithCapacity:count] autorelease];

    for (Item *item in mFilteredList) {
        [sorders addObject:[NSNumber numberWithInteger:item.sorder]];
    }

    // sorder をソート
    [sorders sortUsingSelector:@selector(compare:)];

    // sorder を item に戻す
    [[Database instance] beginTransaction];
    int i = 0;
    for (Item *item in mFilteredList) {
        NSNumber *sorder = [sorders objectAtIndex:i++];
        if (item.sorder != sorder.intValue) {
            item.sorder = sorder.intValue;
            [item save];
        }
    }
    [[Database instance] commitTransaction];
	
    // Filter されたデータだけでなく、元データをソートしておく必要がある。
    // TBD : SmartShelf の場合、元データがどこにあるのかわからないので、
    // 全部の棚をソートしなければならない。
    for (Shelf *s in [[DataModel sharedDataModel] shelves]) {
        [s sortBySorder];
    }
}

@end
