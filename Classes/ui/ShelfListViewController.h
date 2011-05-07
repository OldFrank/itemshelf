// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "Common.h"
#import "DataModel.h"
#import "EditShelfViewController.h"

@class ItemListViewController;

@interface ShelfListViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
{
    IBOutlet UITableView *tableView;
	
    UIImage *normalShelfImage;
    UIImage *smartShelfImage;
    
    BOOL isEditing;
    BOOL needRefreshAd;

    // iPad
    IBOutlet ItemListViewController *splitItemListViewController;
}

@property(nonatomic,retain) UITableView *tableView;

- (IBAction)addShelfButtonTapped:(id)sender;
- (IBAction)scanButtonTapped:(id)sender;
- (IBAction)actionButtonTapped:(id)sender;

- (void)reload;
- (void)addShelf;
- (int)getRow:(NSIndexPath *)indexPath;

@end
