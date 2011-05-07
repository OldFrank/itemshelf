// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <arpa/inet.h>
#import <fcntl.h>
#import <sys/types.h>
#import <sys/stat.h>
#import <sys/uio.h>
#import <unistd.h>

#import "TmiWebServer.h"
#import "BackupServer.h"
#import "Item.h"
#import "AppDelegate.h"
#import "BackupUtil.h"

@implementation BackupServer
//@synthesize filePath;
@synthesize dataName;

- (id)init
{
    self = [super init];
    if (self) {
        dataName = nil;
    }
    return self;
}

- (void)dealloc
{
    [dataName release];
    [super dealloc];
}

- (void)requestHandler:(NSString*)path body:(char *)body bodylen:(int)bodylen
{
    NSString *dataPath = [NSString stringWithFormat:@"/%@", dataName];

    // Request to '/' url.
    if ([path isEqualToString:@"/"])
    {
        [self sendIndexHtml];
    }

    // download
    else if ([path hasPrefix:dataPath]) {
        [self sendBackup];
    }
            
    // upload
    else if ([path isEqualToString:@"/restore"]) {
        [self parseBody:body bodylen:bodylen];
    }

    else {
        [super requestHandler:path body:body bodylen:bodylen];
    }
}

/**
   Send top page
*/
- (void)sendIndexHtml
{
    [self sendString:@"HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n"];

    [self sendString:@"<html><body>"];
    [self sendString:@"<h1>Backup</h1>"];

    NSString *formAction =
        [NSString stringWithFormat:@"<form method=\"get\" action=\"/%@\">", dataName];
    [self sendString:formAction];
    [self sendString:@"<input type=submit value=\"Backup\">"];
    [self sendString:@"</form>"];

    [self sendString:@"<h1>Restore</h1>"];
    [self sendString:@"<form method=\"post\" enctype=\"multipart/form-data\"action=\"/restore\">"];
    [self sendString:@"Select file to restore : <input type=file name=filename><br>"];
    [self sendString:@"<input type=submit value=\"Restore\"></form>"];

    [self sendString:@"</body></html>"];
}

/**
   Send backup file
*/
- (void)sendBackup
{
#if 0
    // DB only...
    int f = open([filePath UTF8String], O_RDONLY);
#else
    // ZIP
    if (![BackupUtil zipBackupFile]) {
        // TBD
        return;
    }
    int f = open([[BackupUtil backupFilePath] UTF8String], O_RDONLY);
#endif

    if (f < 0) {
        // file open error...
        // TBD
        return;
    }

    [self sendString:@"HTTP/1.0 200 OK\r\nContent-Type:application/octet-stream\r\n\r\n"];

    char buf[1024];
    for (;;) {
        int len = read(f, buf, sizeof(buf));
        if (len == 0) break;

        write(serverSock, buf, len);
    }
    close(f);
}

/**
   Parse body (mime multipart)
*/
- (void)parseBody:(char *)body bodylen:(int)bodylen
{
    //NSLog(@"%s", body);

    // get mimepart delimiter
    char *p = strstr(body, "\r\n");
    if (!p) return;
    *p = 0;
    char *delimiter = body;

    // find data start pointer
    p = strstr(p + 2, "\r\n\r\n");
    if (!p) return;
    char *start = p + 4;

    // find data end pointer
    char *end = NULL;
    int delimlen = strlen(delimiter);
    for (p = start; p < body + bodylen; p++) {
        if (strncmp(p, delimiter, delimlen) == 0) {
            end = p - 2; // previous new line
            break;
        }
    }
    if (!end) return;

    [self restore:start datalen:end - start];
}

/**
   Restore from backup file
*/
- (void)restore:(char *)data datalen:(int)datalen
{
    const char zipheader[4] = {0x50, 0x4b, 0x03, 0x04};
    BOOL isZip = NO;

    // Check data format
    if (memcmp(data, zipheader, 4) == 0) {
        // okey its zip file
        isZip = YES;
    }
    else if (strncmp(data, "SQLite format 3", 15) != 0) {
        [self sendString:@"HTTP/1.0 200 OK\r\nContent-Type:text/html\r\n\r\n"];
        [self sendString:@"This is not itemshelf database file. Try again."];
        return;
    }

    // okay, save data between start and end.
    int f = -1;

    NSString *filename;
    if (isZip) {
        // save to zip file
        filename = [BackupUtil backupFilePath];

    } else {
        // save to DB directly
        filename = [[Database instance] dbPath:@"itemshelf.db"]; // TODO: filename
    }
    NSLog(@"restore file:%@", filename);
    f = open([filename UTF8String], O_CREAT|O_WRONLY, 0644);
    if (f < 0) {
        // TBD;
        NSLog(@"open failed:%s", strerror(errno));
        return;
    }
    chmod([filename UTF8String], S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);

    char *p = data;
    char *end = data + datalen;
    while (p < end) {
        int len = write(f, p, end - p);
        p += len;
    }
    close(f);

    // Clear all image data
    [Item deleteAllImageCache];
    
    if (isZip) {
        BOOL result = [BackupUtil unzipBackupFile];
        [BackupUtil deleteBackupFile];
        if (!result) {
            [self sendString:@"HTTP/1.0 200 OK\r\nContent-Type:text/html\r\n\r\n"];
            [self sendString:@"Restoration failed. Try again..."];
            return;
        }
    }

    // send reply
    [self sendString:@"HTTP/1.0 200 OK\r\nContent-Type:text/html\r\n\r\n"];
    [self sendString:@"Restore completed. Please restart the application."];

    // terminate application ...
    //[[UIApplication sharedApplication] terminate];
    exit(0);
}

@end
