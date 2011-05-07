// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// Virtual Shelf

#import "Item.h"
#import "Shelf.h"
#import "DataModel.h"

@implementation Shelf(SmartShelf)

static NSMutableArray *titleFilterStrings = nil;
static NSMutableArray *authorFilterStrings = nil;
static NSMutableArray *manufacturerFilterStrings = nil;
static NSMutableArray *tagsFilterStrings = nil;

/**
   Update all items in smart shelves.
*/
- (void)updateSmartShelf:(NSMutableArray *)shelves
{
    if (mShelfType == ShelfTypeNormal) return;

    [mArray removeAllObjects];

    titleFilterStrings = [self _makeFilterStrings:mTitleFilter];
    authorFilterStrings = [self _makeFilterStrings:mAuthorFilter];
    manufacturerFilterStrings = [self _makeFilterStrings:mManufacturerFilter];
    tagsFilterStrings = [self _makeFilterStrings:mTagsFilter];

    for (Shelf *shelf in shelves) {
        if (shelf.shelfType != ShelfTypeNormal) continue;

        for (Item *item in shelf.array) {
            if ([self _isMatchSmartShelf:item]) {
                [mArray addObject:item];
            }
        }
    }
    [self sortBySorder];
}

/**
   Returns array of filter tokens, which is separated with comma delimiter. (private)
*/ 
- (NSMutableArray *)_makeFilterStrings:(NSString *)filter
{
    return [filter splitWithDelimiter:@","];
}

/**
   Check if the item is match to the smart shelf (private)
*/
- (BOOL)_isMatchSmartShelf:(Item *)item
{
    if (mShelfType == ShelfTypeNormal) {
        return NO;
    }

    BOOL result;
    result = [self _isMatchSmartFilter:titleFilterStrings value:item.name];
    if (!result) return NO;

    result = [self _isMatchSmartFilter:authorFilterStrings value:item.author];
    if (!result) return NO;

    result = [self _isMatchSmartFilter:manufacturerFilterStrings value:item.manufacturer];
    if (!result) return NO;

    result = [self _isMatchSmartFilter:tagsFilterStrings value:item.tags];
    if (!result) return NO;

    if (item.star < mStarFilter) return NO;

    return YES;
}

/**
   Check if the item is match to the filter tokens (private)
*/
- (BOOL)_isMatchSmartFilter:(NSMutableArray *)filterStrings value:(NSString*)value
{
    if (filterStrings.count == 0) return YES;
	
    for (NSString *filter in filterStrings) {
        NSRange range = [value rangeOfString:filter options:NSCaseInsensitiveSearch];
        if (range.location != NSNotFound) {
            return YES;
        }
    }
    return NO;
}

@end
