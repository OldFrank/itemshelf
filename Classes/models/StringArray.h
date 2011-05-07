// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "Common.h"

/**
   Array of string, extension to the NSArray
*/
@interface NSArray (StringArray)
- (NSString*)stringAtIndex:(int)index;
- (int)findString:(NSString*)string;
@end

/**
   Array of string, extension to the NSMutableArray
*/
@interface NSMutableArray (StringArray)
- (void)sortByString;
@end

