// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
  ItemShelf for iPhone/iPod touch

  Copyright (c) 2008, ItemShelf Development Team. All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer. 

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution. 

  3. Neither the name of the project nor the names of its contributors
  may be used to endorse or promote products derived from this software
  without specific prior written permission. 

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "Database.h"
#import "AppDelegate.h"
#import "Item.h"
#import "Shelf.h"
#import "DateFormatter2.h"

@implementation ItemshelfDatabase

- (id)init
{
    self = [super init];
    if (dateFormatter == nil) {
        dateFormatter = [[DateFormatter2 alloc] init];
        [dateFormatter setTimeZone: [NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [dateFormatter setDateFormat: @"yyyyMMddHHmm"];
    }
	
    return self;
}


- (void)dealloc
{
    [dateFormatter release];
    dateFormatter = nil;
    [super dealloc];
}

/**
   Return database file name
*/
- (NSString*)dbPath
{
    NSString *dbPath = [AppDelegate pathOfDataFile:@"itemshelf.db"];
    NSLog(@"dbPath = %@", dbPath);

    return dbPath;
}

- (NSString*)_oldDbPath
{
    NSString *oldDbPath = [AppDelegate pathOfDataFile:@"iWantThis.db"];
    NSLog(@"oldDbPath = %@", oldDbPath);

    return oldDbPath;
}

// Override
- (BOOL)open:(NSString *)dbname
{
    // migrate old database...
    NSString *oldDbPath = [self dbPath:"iWantThis.db"];
    BOOL isExistOldDb = [fileManager fileExistsAtPath:oldDbPath];

    NSString *dbPath = [self dbPath:dbname];
    BOOL isExistDb = [fileManager fileExistsAtPath:dbPath];
    
    if (isExistOldDb) {
        if (isExistedDb) {
            [fileManager removeItemAtPath:oldDbPath error:NULL];
        } else {
            [fileManager moveItemAtPath:oldDbPath toPath:dbPath error:NULL];
        }
    }

    BOOL ret = [super open:dbname];

    // migrate
    [Shelf migrate];
    [Item migrate];

    return isExistedDb;
}

//////////////////////////////////////////////////////////////////////////////////
// Utility


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

/**
   Generate NSDate from C-string
*/
+ (NSDate*)dateFromCString:(const char *)str
{
    NSDate *date = [dateFormatter dateFromString:
                                      [NSString stringWithCString:str encoding:NSUTF8StringEncoding]];
    return date;
}

/**
   Get C-string from NSDate
*/
+ (const char *)cstringFromDate:(NSDate*)date
{
    const char *s = [[dateFormatter stringFromDate:date] UTF8String];
    return s;
}

@end
