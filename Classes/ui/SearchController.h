// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "WebApi.h"
#import "Shelf.h"

@class SearchController;

@protocol SearchControllerDelegate
- (void)searchControllerFinish:(SearchController*)controller result:(BOOL)result;
@end

/**
  Search Controller

  This class execute item search with web API, and show result with ItemView.
  Also execute some UI control (activity indicator etc.)

  To use this, create instance with newController method, set up
  properties, then call searchXXX method. 
  Following properties should be set.

  - delegate (option) : Delegate to callback when search finished.
  - viewController (mandatory) : Current view controller.
  - selectedShelf (option) : Current selected shelf.
  - country (option) : Country code to search.

  This is abstract class. You must inherit this class and override
  searchWithCode: and searchWithTitle:withIndex: method.
*/
@interface SearchController : NSObject <WebApiDelegate>
{
    id<SearchControllerDelegate> delegate;
    UIViewController *viewController;

    Shelf *selectedShelf;

    UIActivityIndicatorView *activityIndicator;
    BOOL autoRegisterShelf;
}

@property(nonatomic,assign) id<SearchControllerDelegate> delegate;
@property(nonatomic,retain) UIViewController *viewController;
@property(nonatomic,retain) Shelf *selectedShelf;

+ (SearchController *)newController;

- (void)search:(WebApi *)api withCode:(NSString*)code;
//- (void)search:(WebApi *)api withTitle:(NSString *)title withIndex:(NSString*)searchIndex;
- (void)search:(WebApi *)api key:(NSString *)key searchKeyType:(SearchKeyType)searchKeyType index:(NSString*)searchIndex;

- (void)_showActivityIndicator;
- (void)_dismissActivityIndicator;
	
@end
