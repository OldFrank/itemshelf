// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Common.h"
#import "GenEditTextViewController.h"

@class EditTagsViewController;

/**
   EditTagsView delegate protocol
*/
@protocol EditTagsViewDelegate
/**
   Called when list item is selected.
*/
- (void)editTagsViewChanged:(EditTagsViewController*)vc;
@end

/**
   Generic list selection view controller
*/
@interface EditTagsViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource, GenEditTextViewDelegate>
{
    id<EditTagsViewDelegate> delegate;     ///< delegate

    UITableView *tableView;

    NSMutableArray *allTags;
    NSMutableArray *tags;

    BOOL canAddTags;
}

@property(nonatomic,retain) UITableView *tableView;
@property(nonatomic,assign) id<EditTagsViewDelegate> delegate;
@property(nonatomic,assign) BOOL canAddTags;

- (id)initWithTags:(NSString *)a_tags delegate:(id<EditTagsViewDelegate>)a_delegate;
- (NSString *)tags;

- (void)_doneAction:(id)sender;

@end
