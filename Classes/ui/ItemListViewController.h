// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// アイテム一覧を表示するビューコントローラ
//   History, iWant, iHave で共通に使用するクラス

#import <UIKit/UIKit.h>
#import "Common.h"
#import "ShelfListViewController.h"
#import "Shelf.h"
#import "Item.h"
#import "ItemListModel.h"
#import "StringArray.h"
#import "GenSelectListViewController.h"

/**
   Extended UITableView class with touch event handlers.
   
   This is needed to get X-coordinate for 4-items per row mode.
*/
@interface UITableViewWithTouchEvent : UITableView

@end

@interface ItemListViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, 
     ItemDelegate, GenSelectListViewDelegate, UIActionSheetDelegate,
     UISplitViewControllerDelegate>
{
    UITableViewWithTouchEvent *tableView;
    UISearchBar *searchBar;

    IBOutlet UIToolbar *toolbar;
    IBOutlet UIBarButtonItem *scanButton;
    IBOutlet UIBarButtonItem *filterButton;
    IBOutlet UIBarButtonItem *configButton; // iPad
    
    ItemListModel *model;

    // iPad
    IBOutlet ShelfListViewController *splitShelfListViewController;
    UIPopoverController *popoverController;
}

@property(nonatomic,assign) Shelf *shelf;
@property(nonatomic,retain) UIPopoverController *popoverController;

- (void)reload;
- (void)setShelf:(Shelf*)shelf;
- (void)updateTitle;
- (void)setFilter:(NSString *)filter;

- (IBAction)toggleSearchBar:(id)sender;
- (void)showSearchBar;
- (void)hideSearchBar;
- (IBAction)toggleCellView:(id)sender;
- (IBAction)scanButtonTapped:(id)sender;
- (IBAction)filterButtonTapped:(id)sender;
- (IBAction)sortButtonTapped:(id)sender;
- (IBAction)configButtonTapped:(id)sender; // ipad

- (int)_calcNumMultiItemsPerLine;

@end
