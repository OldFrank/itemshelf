// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
// AdCell.m
//

// Note:
//   AdMob : size = 320x50

#import "AdCell.h"
#import "Common.h"

/////////////////////////////////////////////////////////////////////
// AdCell

@implementation AdCell

static GADBannerView *sAdBannerView = nil;

+ (CGFloat)adCellHeight
{
    return 50; // AdMob
}

+ (AdCell *)adCell:(UITableView *)tableView parentViewController:(UIViewController *)parentViewController
{
    NSString *identifier = @"AdCell";

    AdCell *cell = (AdCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[AdCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    sAdBannerView.rootViewController = parentViewController;

    return cell;
}

- (UITableViewCell *)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier
{
    self = [super initWithStyle:style reuseIdentifier:identifier];

    // 広告を作成する
    if (sAdBannerView == nil) {
        CGRect frame = CGRectMake(0, 0, 320, 50);
        sAdBannerView = [[GADBannerView alloc] initWithFrame:frame];
        sAdBannerView.adUnitID = ADMOB_PUBLISHER_ID;
    }
        
    CGRect frame = sAdBannerView.frame;
    frame.origin.x = (self.frame.size.width - frame.size.width) / 2;
    frame.origin.y = 0;
    sAdBannerView.frame = frame;
    sAdBannerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.contentView addSubview:sAdBannerView];

    // リクエスト開始
    [sAdBannerView loadRequest:[GADRequest request]];
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}

@end
