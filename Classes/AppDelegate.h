// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// Application Delegate

#import <UIKit/UIKit.h>
#import "Common.h"
#import "SearchController.h"
#import "ShelfListViewController.h"
#import "ItemListViewController.h"

#import "DropboxSDK.h"

/**
   Application delegate
*/
@interface AppDelegate : NSObject <UIApplicationDelegate, SearchControllerDelegate, DBSessionDelegate>
{
    IBOutlet UIWindow *window;
    IBOutlet UINavigationController *navigationController;

    // iPad
    IBOutlet UISplitViewController *splitViewController;
    IBOutlet ShelfListViewController *shelfListViewController;
    IBOutlet ItemListViewController *itemListViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

+ (NSString*)pathOfDataFile:(NSString*)filename;

+ (void)reload;
- (void)_reload;
- (void)reportAppOpenToAdMob;

@end
