// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "BackupUtil.h"
#import "AppDelegate.h"
#import "ZipArchive.h"

@implementation BackupUtil

/**
 * バックアップ Zip ファイル名を返す (パス含まず)
 */
+ (NSString *)backupFileName
{
    return BACKUP_FILE_NAME;
}

/**
 * バックアップ Zip ファイルのフルパス名を取得
 */
+ (NSString *)backupFilePath
{
    return [AppDelegate pathOfDataFile:BACKUP_FILE_NAME];
}

/**
 * バックアップファイルを圧縮する
 */
+ (BOOL)zipBackupFile
{
    NSString *dir = [AppDelegate pathOfDataFile:nil];

    // ファイル一覧取得
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager subpathsAtPath:dir];
    
    ZipArchive *zip = [[[ZipArchive alloc] init] autorelease];
    [zip CreateZipFile2:[self backupFilePath]];

    for (NSString *file in files) {
        if ([file hasSuffix:@"db"] || [file hasSuffix:@"jpg"]) {
            NSString *fullpath = [dir stringByAppendingPathComponent:file];
            [zip addFileToZip:fullpath newname:file];
        }
    }

    BOOL result = [zip CloseZipFile2];
    return result;
}

/**
 * バックアップファイルを復元する
 */
+ (BOOL)uzipBackupFile
{
    NSString *dir = [AppDelegate pathOfDataFile:nil];

    ZipArchive *zip = [[[ZipArchive alloc] init] autorelease];
    if (![zip UnzipOpenFile:[self backupFilePath]]) {
        // no file
        return NO;
    }

    [zip UnzipFileTo:dir overWrite:YES];
    [zip UnzipCloseFile];
    
    return YES;
}

@end
