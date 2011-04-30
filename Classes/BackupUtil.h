// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

/**
   Web server for backup and restore
*/
@interface BackupUtil : NSObject
{
}

+ (BOOL)zipBackupFile;
+ (BOOL)unzipBackupFile;

+ (NSString *)backupFilePath;

@end
