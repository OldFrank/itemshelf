// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AppDelegate.h"
#import "GenSelectListViewController.h"

@implementation GenSelectListViewController

@synthesize delegate, list, identifier, selectedIndex, isLocalize;

/**
   Generate GenSelectListViewController

   @param[in] delegate Delegate
   @param[in] ary Array of option strings
   @param[in] title Title of this view
   @param[in] id User defined identifier
   @return Instance of GenSelectListViewController
*/
+ (GenSelectListViewController *)genSelectListViewController:(id<GenSelectListViewDelegate>)a_delegate array:(NSArray*)ary title:(NSString*)title
{
    GenSelectListViewController *vc =
        [[[GenSelectListViewController alloc]
             init:a_delegate array:ary title:title] autorelease];

    return vc;
}

- (id)init:(id<GenSelectListViewDelegate>)a_delegate array:(NSArray*)ary title:(NSString*)a_title
{
    self = [super initWithNibName:@"GenSelectListView" bundle:nil];
    if (self) {
        self.delegate = a_delegate;
        self.list = ary;
        self.title = a_title;
        self.identifier = -1;
        self.isLocalize = YES;
    }
    return self;
}    

- (void)dealloc
{
    [list release];
    [super dealloc];
}

- (void)viewDidLoad
{
    self.navigationItem.leftBarButtonItem =
        [[[UIBarButtonItem alloc]
             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
             target:self
             action:@selector(_cancelAction:)] autorelease];
}

/**
   Returns selected string
*/
- (NSString *)selectedString
{
    return [list objectAtIndex:selectedIndex];
}

- (void)_closeView
{
    if (self.navigationController.viewControllers.count == 1) {
        [self.navigationController dismissModalViewControllerAnimated:YES];
        [AppDelegate reload];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)_cancelAction:(id)sender
{
    [self _closeView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self tableView] reloadData];
}

/**
   @name Table view delegate / data source
*/
//@{
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [list count];
}

// 行の内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *MyIdentifier = @"genSelectListViewCells";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
    }
    if (indexPath.row == self.selectedIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    NSString *text = [list objectAtIndex:indexPath.row];
    if (self.isLocalize) {
        cell.textLabel.text = NSLocalizedString(text, @"");
    } else {
        cell.textLabel.text = text;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath.row;
    [delegate genSelectListViewChanged:self];

    [self _closeView];
}

//@}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [Common isSupportedOrientation:interfaceOrientation];
}

@end
