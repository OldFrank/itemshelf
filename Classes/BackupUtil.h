// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-


#define BACKUP_FILE_NAME  @"ItemShelfBackup.zip"

@interface BackupUtil : NSObject
{
}

+ (BOOL)zipBackupFile;
+ (BOOL)unzipBackupFile;

+ (NSString *)backupFileName;
+ (NSString *)backupFilePath;

@end
