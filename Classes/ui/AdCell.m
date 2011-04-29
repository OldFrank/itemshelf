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

#define REUSE_IDENTIFIER @"AdCell"

+ (CGFloat)adCellHeight
{
    return 50; // AdMob
}

+ (AdCell *)adCell:(UITableView *)tableView parentViewController:(UIViewController *)parentViewController
{
    AdCell *cell = (AdCell*)[tableView dequeueReusableCellWithIdentifier:REUSE_IDENTIFIER];
    if (cell == nil) {
        cell = [[[AdCell alloc] init:parentViewController] autorelease];
    }

    return cell;
}

- (id)init:(UIViewController *)rootViewController
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:REUSE_IDENTIFIER];

    // 広告を作成する
    CGRect frame = CGRectMake(0, 0, 320, 50);
    mAdBannerView = [[[GADBannerView alloc] initWithFrame:frame] autorelease];
    mAdBannerView.adUnitID = ADMOB_PUBLISHER_ID;
    mAdBannerView.delegate = self;

    frame = mAdBannerView.frame;
    frame.origin.x = (self.frame.size.width - frame.size.width) / 2;
    frame.origin.y = 0;
    mAdBannerView.frame = frame;
    mAdBannerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.contentView addSubview:mAdBannerView];

    // リクエスト開始
    [mAdBannerView loadRequest:[GADRequest request]];
    
    return self;
}

- (void)dealloc {
    mAdBannerView.delegate = nil;
    [super dealloc];
}

#pragma mark - AdMob : GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    NSLog(@"AdMob loaded");
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    if (mAdBannerView.hasAutoRefreshed) {
        // auto refresh failed, but previous ad is effective.
        NSLog(@"AdMob auto refresh failed");
    } else {
        NSLog(@"AdMob initial load failed");
    }
}

@end
