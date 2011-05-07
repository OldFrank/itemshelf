// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "Database.h"
#import "AppDelegate.h"
#import "Item.h"
#import "Shelf.h"
#import "DateFormatter2.h"
#import "ItemshelfDatabase.h"

@implementation ItemshelfDatabase

// Override
- (BOOL)open:(NSString *)dbname
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // migrate old database...
    NSString *oldDbPath = [self dbPath:@"iWantThis.db"];
    BOOL isExistOldDb = [fileManager fileExistsAtPath:oldDbPath];

    NSString *dbPath = [self dbPath:dbname];
    BOOL isExistDb = [fileManager fileExistsAtPath:dbPath];
    
    if (isExistOldDb) {
        if (isExistDb) {
            [fileManager removeItemAtPath:oldDbPath error:NULL];
        } else {
            [fileManager moveItemAtPath:oldDbPath toPath:dbPath error:NULL];
        }
    }

    return [super open:dbname];
}

// Override
- (NSDateFormatter *)dateFormatter
{
    static DateFormatter2 *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[DateFormatter2 alloc] init];
        [dateFormatter setTimeZone: [NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [dateFormatter setDateFormat: @"yyyyMMddHHmm"];
    }
    return dateFormatter;
}

@end
