// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "TmiWebServer.h"

/**
   Web server for backup and restore
*/
@interface BackupServer : TmiWebServer
{
    //NSString *filePath;
    NSString *dataName;
}

//@property(nonatomic,retain) NSString *filePath;
@property(nonatomic,retain) NSString *dataName;

- (void)sendIndexHtml;
- (void)sendBackup;
- (void)parseBody:(char*)body bodylen:(int)bodylen;
- (void)restore:(char*)data datalen:(int)datalen;

@end
