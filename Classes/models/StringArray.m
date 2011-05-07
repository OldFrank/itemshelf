// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "StringArray.h"

@implementation NSArray (StringArray)

/**
   Returns string at index

   @param[in] index Index of string.
   @return string
*/
- (NSString*)stringAtIndex:(int)index
{
    return (NSString*)[self objectAtIndex:index];
}

/**
   Search string in the array.

   @param[in] string String to search.
   @return Index of found string. If no string found, returns -1.
*/
- (int)findString:(NSString*)string
{
    int i = 0;
    for (NSString *s in self) {
        if ([string isEqualToString:s]) {
            return i;
        }
        i++;
    }
    return -1; // not found
}

@end

@implementation NSMutableArray (StringArray)

// ソート
static int compareByString(NSString *t1, NSString *t2, void *context)
{
    return [t1 compare:t2];
}

/**
   Sort by string
*/
- (void)sortByString
{
    [self sortUsingFunction:compareByString context:NULL];
}

@end
