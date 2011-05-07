// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "StarCell.h"

@implementation StarCell

#define REUSE_CELL_ID @"StarCellId"

#define CELL_HEIGHT 42
#define CELL_WIDTH 280
#define STAR_IMAGE_WIDTH 120
#define STAR_IMAGE_HEIGHT 22

+ (StarCell *)getCell:(UITableView *)tableView star:(int)star
{
    StarCell *cell = (StarCell*)[tableView dequeueReusableCellWithIdentifier:REUSE_CELL_ID];
    if (cell == nil) {
        cell = [[[StarCell alloc] init] autorelease];
    }
    [cell setStar:star];
    return cell;
}

- (id)init
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:REUSE_CELL_ID];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    // スター画像領域
    imageView =
        [[[UIImageView alloc]
          initWithFrame:CGRectMake((CELL_WIDTH - STAR_IMAGE_WIDTH) / 2, (CELL_HEIGHT - STAR_IMAGE_HEIGHT) / 2,
                                   STAR_IMAGE_WIDTH, STAR_IMAGE_HEIGHT)] autorelease];
    imageView.tag = 0;
    imageView.autoresizingMask = 0;
    imageView.contentMode = UIViewContentModeScaleAspectFit; // 画像のアスペクト比を変えないようにする。
    imageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:imageView];

    return self;
}

- (void)setStar:(int)star
{
    static UIImage *starImages[6];
    if (starImages[0] == nil) {
        // initial
        int i;
        for (i = 0; i <= 5; i++) {
            NSString *name = [NSString stringWithFormat:@"Star%d", i];
            starImages[i] = [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@"png"]] retain];
        }
    }

    ASSERT(0 <= star && star <= 5);
    ASSERT(starImages[star] != nil);
    if (star < 0 || star > 5) star = 0; // safety

    UIImage *img = starImages[star];
    imageView.image = img;
}

@end
