// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "EditStarViewController.h"
#import "DataModel.h"

@implementation EditStarViewController

@synthesize delegate, tableView, star;

- (id)initWithStar:(int)a_star delegate:(id<EditStarViewDelegate>)a_delegate;
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        delegate = a_delegate;
        star = a_star;
    }
    return self;
}

- (void)dealloc
{
    self.tableView = nil;
    self.view = nil;
    [super dealloc];
}

- (void)loadView
{
    self.tableView = [[[UITableView alloc]
                          initWithFrame:[[UIScreen mainScreen] applicationFrame]
                          style:UITableViewStyleGrouped] autorelease];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    tableView.autoresizesSubviews = YES;

    self.view = tableView;

    self.title = NSLocalizedString(@"Star", @"");

#if 0
    self.navigationItem.rightBarButtonItem = 
        [[[UIBarButtonItem alloc]
             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
             target:self
             action:@selector(_doneAction:)] autorelease];
#endif
    [tableView reloadData];
}

- (void)_doneAction:(id)sender
{
    [delegate editStarViewChanged:self];
    [self.navigationController popViewControllerAnimated:YES];
}

/**
   @name Table view delegate / data source
*/
//@{
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

// 行の内容
- (UITableViewCell *)tableView:(UITableView *)a_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    StarCell *cell = [StarCell getCell:a_tableView star:indexPath.row];

    if (indexPath.row == star) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)a_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    star = indexPath.row;
    [self _doneAction:nil];
}

//@}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [Common isSupportedOrientation:interfaceOrientation];
}


@end
