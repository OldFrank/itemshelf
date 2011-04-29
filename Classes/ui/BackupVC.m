// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AppDelegate.h"
#import "BackupVC.h"
#import "DropboxBackup.h"
#import "BackupServer.h"

#define _L(x) NSLocalizedString(x, @"")

@implementation BackupViewController

+ (BackupViewController *)backupViewController:(id<BackupViewDelegate>)delegate
{
    BackupViewController *vc =
        [[[BackupViewController alloc] initWithNibName:@"BackupView" bundle:nil] autorelease];
    [vc setDelegate:delegate];
    return vc;
}

- (void)setDelegate:(id<BackupViewDelegate>)delegate
{
    mDelegate = delegate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem =
        [[[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)] autorelease];
}

- (void)doneAction:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [mDelegate backupViewFinished:self];
}

- (void)dealloc
{
    [mDropboxBackup release];
    [super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Dropbox";

        case 1:
            return _L(@"Internal web server");
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return _L(@"The backup data will be stored as CashFlowBackup.db in root folder of Dropbox.");
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            // dropbox : backup and restore
            return 2;
            
        case 1:
            // internal web backup
            return 1;
    }
    return 0;
}

// 行の内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *MyIdentifier = @"BackupViewCells";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
    }

    NSString *imageName = nil;
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = _L(@"Backup");
                    imageName = @"dropboxBackup";
                    break;
                    
                case 1:
                    cell.textLabel.text = _L(@"Restore");
                    imageName = @"dropboxRestore";
                    break;
            }
            break;
            
        case 1:
            cell.textLabel.text = [NSString stringWithFormat:@"%@ / %@",
                                   _L(@"Backup"),
                                   _L(@"Restore")];
            break;
    }
    
    if (imageName) {
        NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
        cell.imageView.image = [UIImage imageWithContentsOfFile:path];
    }

    return cell;
}

static int sMode;
static BackupServer *backupServer; // TBD

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UIAlertView *alertView;
    
    switch (indexPath.section) {
        case 0:
            // dropbox
            if (mDropboxBackup == nil) {
                mDropboxBackup = [[DropboxBackup alloc] init:self];
            }
            switch (indexPath.row) {
                case 0: // backup
                    [mDropboxBackup doBackup:self];
                    break;
                    
                case 1: //restore
                    alertView = [[[UIAlertView alloc] initWithTitle:_L(@"Warning")
                                                            message:_L(@"RestoreWarning")
                                                           delegate:self 
                                                  cancelButtonTitle:_L(@"Cancel")
                                                  otherButtonTitles:_L(@"Ok"), nil] autorelease];
                    [alertView show];
                    sMode = 0;
                    break;
            }
            break;

        case 1:
            // internal web server
            backupServer = [[BackupServer alloc] init];
            backupServer.dataName = @"itemshelf-backup.zip";

            NSString *url = [backupServer serverUrl];
            BOOL result = NO;
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
                NSString *message = [NSString stringWithFormat:NSLocalizedString(@"WebServerNotation",
                                                                                 @""), url];
                
                v = [[UIAlertView alloc]
                     initWithTitle:NSLocalizedString(@"Backup and restore", @"")
                     message:message
                     delegate:self cancelButtonTitle:NSLocalizedString(@"Close", @"")
                     otherButtonTitles:nil];
                sMode = 1;
            }
            [v show];
            [v release];
            break;
    }
}

#pragma mark UIAlertViewDelegate protocol

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (sMode == 0) {
        if (buttonIndex == 1) { // OK
            // UIAlertView が消えてからすぐに次の View (LoadingView) を表示すると、
            // 次の View が正しく表示されない。このため少し待たせる
            [mDropboxBackup performSelector:@selector(doRestore:) withObject:self afterDelay:0.5];
        }
    } else {
        [backupServer stopServer];
        [backupServer release];
        backupServer = nil;
    }
}

#pragma mark DropboxBackupDelegate

- (void)dropboxBackupStarted:(BOOL)isRestore
{
    NSLog(@"DropboxBackupStarted");
    
    NSString *msg = nil;
    if (isRestore) {
        msg = _L(@"Downloading");
    } else {
        msg = _L(@"Uploading");
    }
    mLoadingView = [[DBLoadingView alloc] initWithTitle:msg];
    mLoadingView.userInteractionEnabled = YES; // 下の View の操作不可にする
    [mLoadingView setOrientation:self.interfaceOrientation];
    [mLoadingView show];
}

- (void)dropboxBackupFinished
{
    NSLog(@"DropboxBackupFinished");
    [mLoadingView dismissAnimated:NO];
    [mLoadingView release];
    mLoadingView = nil;
}

#pragma mark utils

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
