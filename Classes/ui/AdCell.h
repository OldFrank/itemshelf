// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
//  AdCell.h
//

#import <UIKit/UIKit.h>

#import "GADBannerView.h"

#define ADMOB_PUBLISHER_ID      @"a14a925cd4c5c5f" // ItemShelf Lite

@interface AdCell : UITableViewCell <GADBannerViewDelegate> {
    GADBannerView *mAdBannerView;
}

+ (AdCell *)adCell:(UITableView *)tableView parentViewController:(UIViewController *)parentViewController;
+ (CGFloat)adCellHeight;

- (id)init:(UIViewController *)rootViewController;

@end
