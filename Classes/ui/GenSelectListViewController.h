// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Common.h"

@class GenSelectListViewController;

/**
   GenSelectListView delegate protocol
*/
@protocol GenSelectListViewDelegate
/**
   Called when list item is selected.
*/
- (void)genSelectListViewChanged:(GenSelectListViewController*)vc;
@end

/**
   Generic list selection view controller
*/
@interface GenSelectListViewController : UITableViewController
{
    id<GenSelectListViewDelegate> delegate;     ///< delegate
    int identifier;     ///< identifier of this controller (use can use this to identify)
	
    NSArray *list;      ///< list of options
    int selectedIndex;  ///< selected index of options list
    BOOL isLocalize; 
}

@property(nonatomic,assign) id<GenSelectListViewDelegate> delegate;
@property(nonatomic,assign) int identifier;
@property(nonatomic,retain) NSArray *list;
@property(nonatomic,assign) int selectedIndex;
@property(nonatomic,assign) BOOL isLocalize;

+ (GenSelectListViewController *)genSelectListViewController:(id<GenSelectListViewDelegate>)delegate array:(NSArray*)ary title:(NSString*)title;
- (id)init:(id<GenSelectListViewDelegate>)delegate array:(NSArray*)ary title:(NSString*)title;
- (void)_cancelAction:(id)sender;
- (NSString *)selectedString;

@end
