// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// データベースアクセス用のクラス
// sqlite3 のラッパ

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "Common.h"

/**
   Wrapper class of sqlite3 database
*/
@interface ItemshelfDatabase : Database {
}

@end
