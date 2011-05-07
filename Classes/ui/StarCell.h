// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// Star 表示で使用するセル

#import <UIKit/UIKit.h>
#import "Common.h"

@interface StarCell : UITableViewCell
{
    UIImageView *imageView;
}

+ (StarCell *)getCell:(UITableView *)tableView star:(int)star;
- (void)setStar:(int)star;

@end
