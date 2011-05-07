// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AppDelegate.h"
#import "EditShelfViewController.h"
#import "DataModel.h"

@implementation EditShelfViewController

@synthesize shelf, isNew;

// View Controller の生成
+ (EditShelfViewController *)editShelfViewController:(Shelf *)shelf isNew:(BOOL)isNew
{
    EditShelfViewController *vc =
        [[[EditShelfViewController alloc] initWithNibName:@"EditShelfView" bundle:nil] autorelease];
    vc.shelf = shelf;
    vc.isNew = isNew;

    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.rowHeight = 38; // ###
    
    self.navigationItem.title = NSLocalizedString(@"Edit shelf", @"");
    self.navigationItem.rightBarButtonItem =
        [[[UIBarButtonItem alloc]
             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
             target:self
             action:@selector(doneAction:)] autorelease];

    self.navigationItem.leftBarButtonItem =
        [[[UIBarButtonItem alloc]
             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
             target:self
             action:@selector(closeAction:)] autorelease];

    shelfNameField    = [self allocTextInputField:shelf.name placeholder:@"Name"];
    titleField        = [self allocTextInputField:shelf.titleFilter placeholder:@"Title"];
    authorField       = [self allocTextInputField:shelf.authorFilter placeholder:@"Author"];
    manufacturerField = [self allocTextInputField:shelf.manufacturerFilter placeholder:@"Manufacturer"];
    tagsField         = [self allocTextLabelField:shelf.tagsFilter];
    starField         = [self allocTextLabelField:[self _starFilterString:shelf.starFilter]];
}

- (void)didReceiveMemoryWarning {
    //[super didReceiveMemoryWarning];
}

- (void)dealloc {
    [shelf release];

    [shelfNameField release];
    [titleField release];
    [authorField release];
    [manufacturerField release];
    [tagsField release];
    [starField release];

    [super dealloc];
}

- (void)doneAction:(id)sender
{
    shelf.name = shelfNameField.text;
    if (shelf.name == nil) {
        shelf.name = @"";
    }
    shelf.titleFilter = titleField.text;
    shelf.authorFilter = authorField.text;
    shelf.manufacturerFilter = manufacturerField.text;
    shelf.tagsFilter = tagsField.text;
    shelf.starFilter = starFilter;

    if (isNew) {
        // 新規追加
        [[DataModel sharedDataModel] addShelf:shelf];
    } else {
        // 変更
        [shelf save];
    }

    // SmartShelf を更新する
    [shelf updateSmartShelf:[[DataModel sharedDataModel] shelves]];
    [self closeAction:sender];
}

- (void)closeAction:(id)sender
{
    [shelfNameField resignFirstResponder];
    [titleField resignFirstResponder];
    [authorField resignFirstResponder];
    [manufacturerField resignFirstResponder];
    //[tagsField resignFirstResponder];

    [self.navigationController dismissModalViewControllerAnimated:YES];
    [AppDelegate reload];
}

- (UITextField*)allocTextInputField:(NSString*)value placeholder:(NSString*)placeholder
{
    UITextField *t = [[UITextField alloc]
                         initWithFrame:CGRectMake(110, 10, 210, 32)];

    t.text = value;
    t.placeholder = NSLocalizedString(placeholder, @"");
    t.font = [UIFont systemFontOfSize:14];
    t.backgroundColor = [UIColor clearColor];
    t.keyboardType = UIKeyboardTypeDefault;
    t.returnKeyType = UIReturnKeyDone;
    t.autocorrectionType = UITextAutocorrectionTypeNo;
    t.autocapitalizationType = UITextAutocapitalizationTypeNone;
	
    t.delegate = self;

    return t;
}

- (UILabel *)allocTextLabelField:(NSString *)value
{
    UILabel *lb = [[UILabel alloc]
                      initWithFrame:CGRectMake(110, 2, 170, 32)];
    lb.text = value;
    lb.font = [UIFont systemFontOfSize:14];
    lb.backgroundColor = [UIColor clearColor];
    return lb;
}

- (BOOL)textFieldShouldReturn:(UITextField*)t
{
    [t resignFirstResponder];
    return YES;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (shelf.shelfType == ShelfTypeNormal) {
        return 1; // 棚の名前だけ
    }
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
    case 0:
        cell = [self textViewCell:@"Name" view:shelfNameField];
        break;
    case 1:
        cell = [self textViewCell:@"Title" view:titleField];
        break;
    case 2:
        cell = [self textViewCell:@"Author" view:authorField];
        break;
    case 3:
        cell = [self textViewCell:@"Manufacturer" view:manufacturerField];
        break;
    case 4:
        cell = [self textViewCell:@"Tags" view:tagsField];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        break;
    case 5:
        cell = [self textViewCell:@"Star" view:starField];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        break;
    }
    return cell;
}

// View つきセルを作成
- (UITableViewCell *)textViewCell:(NSString *)title view:(UIView *)view
{
    NSString *CellIdentifier = @"textViewCell";

    UITableView *tv = (UITableView *)self.view;
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    } else {
        UIView *oldView = [cell.contentView viewWithTag:1];
        [oldView removeFromSuperview];
    }

    cell.textLabel.text = NSLocalizedString(title, @"");
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];

    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    view.tag = 1;
    [cell.contentView addSubview:view];
    [cell.contentView bringSubviewToFront:view];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 4)  {
        // tags
        EditTagsViewController *vc =
            [[EditTagsViewController alloc] initWithTags:tagsField.text delegate:self];
        vc.canAddTags = NO;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
    else if (indexPath.row == 5) {
        // star
        EditStarViewController *vc =
            [[EditStarViewController alloc] initWithStar:shelf.starFilter delegate:self];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
}

- (void)editTagsViewChanged:(EditTagsViewController *)vc
{
    tagsField.text = [vc tags];
    [self.tableView reloadData];
}

- (void)editStarViewChanged:(EditStarViewController *)vc
{
    starFilter = vc.star;
    starField.text = [self _starFilterString:starFilter];
    [self.tableView reloadData];
}

- (NSString *)_starFilterString:(int)n
{
    NSString *andAbove = NSLocalizedString(@"and above", @"");
    NSString *starString;

    switch (n) {
    default: starString = @"☆☆☆☆☆"; break;
    case 1: starString = @"★☆☆☆☆"; break;
    case 2: starString = @"★★☆☆☆"; break;
    case 3: starString = @"★★★☆☆"; break;
    case 4: starString = @"★★★★☆"; break;
    case 5: starString = @"★★★★★"; break;
    }
    
    if (n == 5) {
        return starString;
    }
    return [NSString stringWithFormat:@"%@ %@", starString, andAbove];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [Common isSupportedOrientation:interfaceOrientation];
}


@end
