// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#define BACKUP_FILE_NAME  @"ItemShelfBackup.zip"

@interface BackupUtil : NSObject
{
}

+ (BOOL)zipBackupFile;
+ (BOOL)unzipBackupFile;
+ (void)deleteBackupFile;

+ (NSString *)backupFileName;
+ (NSString *)backupFilePath;

@end
