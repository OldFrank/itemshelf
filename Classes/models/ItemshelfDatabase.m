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
