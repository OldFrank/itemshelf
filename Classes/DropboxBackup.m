// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "DropboxBackup.h"
#import "Database.h"
#import "AppDelegate.h"
#import "BackupUtil.h"

#define MODE_BACKUP 0
#define MODE_RESTORE 1

@implementation DropboxBackup

- (id)init:(id<DropboxBackupDelegate>)delegate
{
    self = [super init];
    if (self) {
        mDelegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    [mRestClient release];
    [super dealloc];
}

- (void)doBackup:(UIViewController *)viewController
{
    // create backup archive
    if (![BackupUtil zipBackupFile]) {
        NSLog(@"zipBackupFile failed...");
        return;
    }
    
    mMode = MODE_BACKUP;
    mViewController = viewController;
    [self _login];
}

- (void)doRestore:(UIViewController *)viewController
{
    mMode = MODE_RESTORE;
    mViewController = viewController;
    [self _login];
}

- (void)unlink
{
    DBSession *session = [DBSession sharedSession];
    if ([session isLinked]) {
        [session unlink];
    }

    [self _showResult:@"Your dropbox account has been unlinked"];
}

- (void)_login
{
    DBSession *session = [DBSession sharedSession];
    
    // ログイン処理
    if (![session isLinked]) {
        // 未ログイン
        DBLoginController *controller = [[DBLoginController new] autorelease];
        controller.delegate = self;
        [controller presentFromController:mViewController];
    } else {
        // ログイン済み
        [self _exec];
    }
}

- (void)_exec
{
    NSString *fileName = [BackupUtil backupFileName];
    NSString *localPath = [BackupUtil backupFilePath];
    NSString *remotePath = [NSString stringWithFormat:@"/%@", fileName];
    
    switch (mMode) {
        case MODE_BACKUP:
            [self.restClient
             uploadFile:fileName
             toPath:@"/"
             fromPath:localPath];
            [mDelegate dropboxBackupStarted:NO];
            break;

        case MODE_RESTORE:
            // shutdown database
            [DataModel finalize];
            [self.restClient loadFile:remotePath intoPath:localPath];
            [mDelegate dropboxBackupStarted:YES];
            break;
    }
}

- (DBRestClient *)restClient
{
    if (mRestClient == nil) {
    	mRestClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    	mRestClient.delegate = self;
    }
    return mRestClient;
}

#pragma mrk DBRestClientDelegate

// backup finished
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath
{
    [self _showResult:@"Backup done."];

    [BackupUtil deleteBackupFile];
    [mDelegate dropboxBackupFinished];
}

// backup failed
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    [self _showResult:@"Backup failed!"];
    NSLog(@"backup failed: @%", [error description]);
    
    [BackupUtil deleteBackupFile];
    [mDelegate dropboxBackupFinished];
}

// restore done
- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath
{
    [self _showResult:@"Restore done."];
    
    [Item deleteAllImageCache];
    [BackupUtil unzipBackupFile];
    [BackupUtil deleteBackupFile];
    
    [[DataModel sharedDataModel] loadDB];
    [mDelegate dropboxBackupFinished];
}

// restore failed
- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error
{
    [self _showResult:@"Restore failed!"];
    NSLog(@"restore failed: @%", [error description]);
    
    [[DataModel sharedDataModel] loadDB];
    [mDelegate dropboxBackupFinished];
}

- (void)_showResult:(NSString *)message
{
    [[[[UIAlertView alloc] 
       initWithTitle:@"Dropbox" message:message
       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
        autorelease]
        show];
}

#pragma mark DBLoginControllerDelegate methods

- (void)loginControllerDidLogin:(DBLoginController*)controller {
    [self _exec];
}

- (void)loginControllerDidCancel:(DBLoginController*)controller {
    [mDelegate dropboxBackupFinished];
}

@end
