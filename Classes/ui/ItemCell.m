// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "ItemCell.h"

@implementation ItemCell

#define REUSE_CELL_ID @"ItemCellId"

+ (ItemCell *)getCell:(UITableView *)tableView
{
    ItemCell *cell = (ItemCell*)[tableView dequeueReusableCellWithIdentifier:REUSE_CELL_ID];
    if (cell == nil) {
        UIViewController *vc = [[UIViewController alloc] initWithNibName:@"ItemCell" bundle:nil];
        cell = (ItemCell *)vc.view;
        [[cell retain] autorelease];
        [vc release];
    }
    return cell;
}

#if 0 // Old code...

#define TAG_IMAGE   1
#define TAG_DESC    2
#define TAG_DATE    3
#define TAG_STAR    4

- (id)init
{
    static UIImage *backgroundImage = nil;

    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:REUSE_CELL_ID];
    self.selectionStyle = UITableViewCellSelectionStyleNone; // TBD
    //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    CGRect b = self.bounds;
    b.size.height = ITEM_CELL_HEIGHT;
    self.bounds = b;
	
    if (backgroundImage == nil) {
        backgroundImage = [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ItemCellBack" ofType:@"png"]] retain];
    }
	
    // 背景
    UIImageView *backImage = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
    backImage.autoresizingMask = 0; /*UIViewAutoresizingFlexibleWidth;*/
    backImage.image = backgroundImage;
    //[self.contentView addSubview:backImage];
    self.backgroundView = backImage;
	
    // 画像
    UIImageView *imgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, ITEM_CELL_HEIGHT - ITEM_IMAGE_HEIGHT - 8, ITEM_IMAGE_WIDTH, ITEM_IMAGE_HEIGHT)] autorelease];
    imgView.tag = TAG_IMAGE;
    imgView.autoresizingMask = 0;
    imgView.contentMode = UIViewContentModeScaleAspectFit; // 画像のアスペクト比を変えないようにする。
    //imgView.contentMode = UIViewContentModeBottom;
    imgView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:imgView];
    
    int label_x = ITEM_IMAGE_WIDTH + 5;
    int label_width = 320 - label_x - 10;

    // 名称
    UILabel *descLabel = [[[UILabel alloc] initWithFrame:CGRectMake(label_x, 10, label_width, 55)] autorelease];
    descLabel.tag = TAG_DESC;
    descLabel.font = [UIFont systemFontOfSize:15.0];
    descLabel.textColor = [UIColor blackColor];
    //descLabel.backgroundColor = [UIColor grayColor];
    descLabel.backgroundColor = [UIColor clearColor];
    descLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    descLabel.lineBreakMode = UILineBreakModeWordWrap;
    descLabel.numberOfLines = 0;
    [self.contentView addSubview:descLabel];
	
    // 日付
    UILabel *dateLabel = [[[UILabel alloc] initWithFrame:CGRectMake(label_x, 65, label_width - 100, 18)] autorelease];
    dateLabel.tag = TAG_DATE;
    dateLabel.font = [UIFont systemFontOfSize:12.0];
    dateLabel.textColor = [UIColor darkGrayColor];
    //dateLabel.backgroundColor = [UIColor redColor];
    dateLabel.backgroundColor = [UIColor clearColor];
    dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:dateLabel];
    
    // スター
    UILabel *starLabel = [[[UILabel alloc] initWithFrame:CGRectMake(320 - 80, 65, 80, 18)] autorelease];
    starLabel.tag = TAG_STAR;
    starLabel.font = [UIFont systemFontOfSize:16.0];
    starLabel.textColor = [UIColor orangeColor];
    starLabel.backgroundColor = [UIColor clearColor];
    starLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:starLabel];
	
    return self;
}

#endif

- (void)setItem:(Item *)item
{
    static NSDateFormatter *df = nil;

    if (df == nil) {
        df = [[NSDateFormatter alloc] init];
        [df setDateStyle:NSDateFormatterMediumStyle];
        [df setTimeStyle:NSDateFormatterShortStyle];
    }

    mDescLabel.text = item.name;
    mDateLabel.text = [df stringFromDate:item.date];

    NSString *starText = @"☆☆☆☆☆";
    switch (item.star) {
    case 1: starText = @"★☆☆☆☆"; break;
    case 2: starText = @"★★☆☆☆"; break;
    case 3: starText = @"★★★☆☆"; break;
    case 4: starText = @"★★★★☆"; break;
    case 5: starText = @"★★★★★"; break;
    }
    mStarLabel.text = starText;

    // resize image
    UIImage *image = [item getImage:nil];
    mImageView.image = image;
#if 0
    imgView.image = [Common resizeImageWithin:image
                            width:ITEM_IMAGE_WIDTH - ITEM_IMAGE_WIDTH_PADDING
                            height:ITEM_IMAGE_HEIGHT];
#endif
}

@end
