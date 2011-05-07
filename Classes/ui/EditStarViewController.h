// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Common.h"
#import "StarCell.h"

@class EditStarViewController;

/**
   EditStarView delegate protocol
*/
@protocol EditStarViewDelegate
/**
   Called when list item is selected.
*/
- (void)editStarViewChanged:(EditStarViewController*)vc;
@end

/**
   Generic list selection view controller
*/
@interface EditStarViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource>
{
    id<EditStarViewDelegate> delegate;     ///< delegate

    UITableView *tableView;
    int star;
}

@property(nonatomic,retain) UITableView *tableView;
@property(nonatomic,assign) id<EditStarViewDelegate> delegate;
@property(nonatomic,assign) int star;

- (id)initWithStar:(int)a_star delegate:(id<EditStarViewDelegate>)a_delegate;
- (void)_doneAction:(id)sender;

@end
