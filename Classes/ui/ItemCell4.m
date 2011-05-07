// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "ItemCell4.h"

@implementation ItemCell4

#define REUSE_CELL_ID @"ItemCell4Id"

+ (ItemCell4 *)getCell:(UITableView *)tableView numItemsPerCell:(int)n
{
    ItemCell4 *cell = (ItemCell4*)[tableView dequeueReusableCellWithIdentifier:REUSE_CELL_ID];
    if (cell == nil) {
        cell = [[[ItemCell4 alloc] init] autorelease];
    }
    
    [cell setNumItemsPerCell:n];
    
    return cell;
}

- (id)init
{
    static UIImage *backgroundImage = nil;

    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:REUSE_CELL_ID];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    if (backgroundImage == nil) {
        backgroundImage = [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ItemCellBack" ofType:@"png"]] retain];
    }
	
    // 背景
    UIImageView *backImage = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, ITEM_CELL_HEIGHT)] autorelease];
    backImage.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    backImage.image = backgroundImage;
    [self.contentView addSubview:backImage];

	numItemsPerCell = 0;
    imageViews = nil;
    
    return self;
}

- (void)setNumItemsPerCell:(int)n
{
    UIImageView *iv;
    
    // 以前と同じ画像数なら、なにもしない
    if (numItemsPerCell == n) {
        return;
    }
    
    if (imageViews == nil) {
        // 初期化時
        imageViews = [[NSMutableArray alloc] init];
    } else {
        // 画像数変更 (画面回転)
        for (iv in imageViews) {
            [iv removeFromSuperview];
        }
        [imageViews removeAllObjects];
    }
    
    // 画像
    for (int i = 0; i < n; i++) {
        iv = [[[UIImageView alloc]
                       initWithFrame:CGRectMake(ITEM_IMAGE_WIDTH * i,
                                                ITEM_CELL_HEIGHT - ITEM_IMAGE_HEIGHT - 8,
                                                ITEM_IMAGE_WIDTH, ITEM_IMAGE_HEIGHT)]
                      autorelease];
        iv.tag = i + 1;
        iv.autoresizingMask = 0;
        iv.contentMode = UIViewContentModeScaleAspectFit; // 画像のアスペクト比を変えないようにする。
        //imgView.contentMode = UIViewContentModeBottom;
        iv.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:iv];
        
        [imageViews addObject:iv];
    }
}

- (void)setItem:(Item *)item atIndex:(int)index
{
    UIImageView *imgView = (UIImageView *)[imageViews objectAtIndex:index];

    if (item != nil) {
        UIImage *image = [item getImage:nil];
        imgView.image = image;
#if 0
        imgView.image = [Common resizeImageWithin:image
                                width:ITEM_IMAGE_WIDTH - ITEM_IMAGE_WIDTH_PADDING
                                height:ITEM_IMAGE_HEIGHT];
#endif
    } else {
        imgView.image = nil;
    }
}

@end
