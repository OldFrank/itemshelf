// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "ConfigViewController.h"
#import "DataModel.h"
#import "AboutViewController.h"
#import "WebViewController.h"
#import "BackupVC.h"

@implementation ConfigViewController

/*
  - (id)initWithStyle:(UITableViewStyle)style {
  // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
  if (self = [super initWithStyle:style]) {
  }
  return self;
  }
*/

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = NSLocalizedString(@"About", @"");

    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(doneAction:)] autorelease];
}

- (void)dealloc {
    [super dealloc];
}

- (void)doneAction:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return NSLocalizedString(@"Backup", @"");
        case 1:
            return NSLocalizedString(@"About", @"");
    }
    return nil;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: // backup
            return 1;
        case 1: // about
            return 3;
    }
    return 0;
}

// Customize cell heights
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.rowHeight; // default
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ConfigCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;	
	
    switch (indexPath.section) {
        case 0: // backup
            cell.textLabel.text = NSLocalizedString(@"Backup and restore", @"");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
            
        case 1: // about
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = NSLocalizedString(@"Help", @"");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                case 1:
                    cell.textLabel.text = NSLocalizedString(@"Macro lens information", @"");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                case 2:
                    cell.textLabel.text = NSLocalizedString(@"About this software", @"");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
            }
            break;
    }

    return cell;
}

// セルタップ時の処理					
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        // backup
        [self _doBackup];
    }
    else if (indexPath.section == 1) {
        WebViewController *wv;
        AboutViewController *av;
        NSString *urlstring = nil;

        switch (indexPath.row) {
        case 0:
            urlstring = NSLocalizedString(@"HelpURL", @"");
            // fallthrough

        case 1:
            if (urlstring == nil) {
                urlstring = NSLocalizedString(@"MacroLensURL", @"");
            }

            wv = [[[WebViewController alloc] initWithNibName:@"WebView" bundle:nil] autorelease];
            wv.urlString = urlstring;
            [self.navigationController pushViewController:wv animated:YES];
            break;

        case 2:
            av = [[[AboutViewController alloc]
                      initWithNibName:@"AboutView"
                      bundle:nil] autorelease];
            [self.navigationController pushViewController:av animated:YES];
            break;
        }
    }
}

- (void)_doBackup
{
    BackupViewController *vc = [BackupViewController backupViewController:nil]; // TODO: delegate
    [self.navigationController pushViewController:vc animated:YES];
    
#if 0
    BOOL result = NO;
    
    backupServer = [[BackupServer alloc] init];
    backupServer.dataName = @"itemshelf-backup.zip";

    NSString *url = [backupServer serverUrl];
    if (url != nil) {
        result = [backupServer startServer];
    }
    
    UIAlertView *v;
    if (!result) {
        [backupServer release];
        v = [[UIAlertView alloc]
             initWithTitle:@"Error"
             message:NSLocalizedString(@"Cannot start web server.", @"")
             delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", @"")
             otherButtonTitles:nil];
    } else {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"WebServerNotation", @""), url];
        
        v = [[UIAlertView alloc]
             initWithTitle:NSLocalizedString(@"Backup and restore", @"")
             message:message
             delegate:self cancelButtonTitle:NSLocalizedString(@"Close", @"")
             otherButtonTitles:nil];
    }
    [v show];
    [v release];
#endif
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [backupServer stopServer];
    [backupServer release];
    backupServer = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [Common isSupportedOrientation:interfaceOrientation];
}

@end
