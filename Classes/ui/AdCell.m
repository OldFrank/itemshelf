// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */
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

static CGSize getAdSize() {
    if (IS_IPAD) {
        return GAD_SIZE_468x60;
    } else {
        return GAD_SIZE_320x50;
    }
}

+ (CGFloat)adCellHeight
{
    CGSize size = getAdSize();
    return size.height;
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
    CGSize size = getAdSize();
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    
    mAdBannerView = [[[GADBannerView alloc] initWithFrame:frame] autorelease];
    mAdBannerView.adUnitID = ADMOB_PUBLISHER_ID;
    mAdBannerView.delegate = self;
    mAdBannerView.rootViewController = rootViewController;

    frame = mAdBannerView.frame;
    frame.origin.x = (self.frame.size.width - frame.size.width) / 2;
    frame.origin.y = 0;
    mAdBannerView.frame = frame;
    mAdBannerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.contentView addSubview:mAdBannerView];

    // リクエスト開始
    GADRequest *request = [GADRequest request];
    [request setTesting:YES];
    [mAdBannerView loadRequest:request];
    
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
        NSLog(@"AdMob auto refresh failed : %@", [error localizedDescription]);
    } else {
        NSLog(@"AdMob initial load failed : %@", [error localizedDescription]);
    }
}

@end
