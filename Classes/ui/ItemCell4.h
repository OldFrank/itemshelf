// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// ItemListView で使用するセル
//   左側にイメージ、その右にアイテム名称を表示する

#import <UIKit/UIKit.h>
#import "Common.h"
#import "item.h"
#import "ItemCell.h"

@interface ItemCell4 : UITableViewCell
{
    int numItemsPerCell;
    NSMutableArray *imageViews;
}

+ (ItemCell4 *)getCell:(UITableView *)tableView numItemsPerCell:(int)n;

- (void)setNumItemsPerCell:(int)n;
- (void)setItem:(Item *)item atIndex:(int)index;

@end
