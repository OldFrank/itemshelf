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

#define ITEM_CELL_HEIGHT	90
#define ITEM_IMAGE_HEIGHT   77
#define ITEM_IMAGE_WIDTH    80
#define ITEM_IMAGE_WIDTH_PADDING 4

@interface ItemCell : UITableViewCell
{
    IBOutlet UIImageView *mImageView;
    IBOutlet UILabel *mDescLabel;
    IBOutlet UILabel *mDateLabel;
    IBOutlet UILabel *mStarLabel;
}

+ (ItemCell *)getCell:(UITableView *)tableView;
- (void)setItem:(Item *)item;

@end
