// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "SearchController.h"
#import "ItemViewController.h"
#import "WebApi.h"
#import "DataModel.h"

@implementation SearchController

@synthesize delegate, viewController, selectedShelf;

/**
   Create SearchController instance (factory method)
*/
+ (SearchController *)newController
{
    SearchController *c = [[SearchController alloc] init];
    return c;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.delegate = nil;
        self.viewController = nil;
        self.selectedShelf = nil;
        activityIndicator = nil;
    }
    return self;
}

- (void)dealloc
{
    [viewController release];
    [selectedShelf release];

    if (activityIndicator) {
        [activityIndicator removeFromSuperview];
        [activityIndicator release];
    }
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////
// Search functions

/**
   Search item with code

   @param[in] code Code to search
*/
- (void)search:(WebApi *)api withCode:(NSString*)code
{
    [self search:api key:code searchKeyType:SearchKeyCode index:nil];
}

/**
   Search item
*/
- (void)search:(WebApi *)api key:(NSString *)key searchKeyType:(SearchKeyType)searchKeyType index:(NSString*)searchIndex
{
    ASSERT(viewController != nil);
    [self _showActivityIndicator];

    if (searchKeyType == SearchKeyCode) {
        autoRegisterShelf = YES;
    } else {
        autoRegisterShelf = NO;
    }

    api.delegate = self;
    api.searchKey = key;
    api.searchKeyType = searchKeyType;
    api.searchIndex = searchIndex;

    [api retain];
    [api itemSearch];
}

////////////////////////////////////////////////////////////////////////////////////////////
/*
   @name WebApiDelegate
*/
//@{

// 検索成功時の処理
- (void)webApiDidFinish:(WebApi *)api items:(NSMutableArray *)itemArray
{
    [self _dismissActivityIndicator];

    // add history
    DataModel *dm = [DataModel sharedDataModel];
    int count = [itemArray count];

    for (int i = 0; i < count; i++) {
        Item *item = [itemArray objectAtIndex:i];

        // 棚にひも付けをする (登録はまだ)
        if (selectedShelf == nil) {
            item.shelfId = 0; // 未分類
        } else {
            item.shelfId = selectedShelf.pid;
        }
		
        // 重複チェック
        Item *x = [dm findSameItem:item];
        if (x == nil) {
            // 棚に登録
            if (autoRegisterShelf) {
                if (![dm addItem:item]) {
                    [dm alertItemCountOver];
                }
            }
        } else {
            // データ重複 : 置換する
            [x updateWithNewItem:item];
            [itemArray replaceObjectAtIndex:i withObject:x];
        }
    }
	
    // show item view
    NSString *nib = (IS_IPAD) ? @"ItemView-ipad" : @"ItemView";
    ItemViewController *vc = [[[ItemViewController alloc] initWithNibName:nib bundle:nil] autorelease];
    vc.itemArray = itemArray;

    [api release];

    [viewController.navigationController pushViewController:vc animated:YES];

    if (delegate) {
        [delegate searchControllerFinish:self result:YES];
    }
    [self release];
}

// 検索失敗
- (void)webApiDidFailed:(WebApi *)api reason:(int)reason message:(NSString *)message
{
    [self _dismissActivityIndicator];
	
    NSString *reasonString = @"Unknown error";
    switch (reason) {
    case WEBAPI_ERROR_NETWORK:
        reasonString = NSLocalizedString(@"Cannot connect with service", @""); // ### TBD
        break;

    case WEBAPI_ERROR_BADREPLY:
        reasonString = NSLocalizedString(@"Illegal message was received", @"");
        break;

    case WEBAPI_ERROR_NOTFOUND:
        reasonString = NSLocalizedString(@"Cannot find item information", @"");
        break;

    case WEBAPI_ERROR_BADPARAM:
        reasonString = NSLocalizedString(@"Error", @""); // ### ad hoc...
        break;
    }

    if (message) {
        reasonString = [NSString stringWithFormat:@"%@\n(%@)", reasonString, message];
    }

    [Common showAlertDialog:@"Error" message:reasonString];

    [api release];

    if (delegate) {
        [delegate searchControllerFinish:self result:NO];
    }
    [self release];
}

//@}

////////////////////////////////////////////////////////////////////////////////////////////
// ActivityIndicator

- (void)_showActivityIndicator
{
    ASSERT(viewController != nil);
    ASSERT(activityIndicator == nil);


    activityIndicator = [[UIActivityIndicatorView alloc]
                            initWithFrame:CGRectMake(0, 0, viewController.view.bounds.size.width, viewController.view.bounds.size.height)];
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    activityIndicator.backgroundColor = [UIColor grayColor];
    activityIndicator.contentMode = UIViewContentModeCenter;
    activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [viewController.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
}

- (void)_dismissActivityIndicator
{
    ASSERT(viewController != nil);
    ASSERT(activityIndicator);

    [activityIndicator stopAnimating];
    [activityIndicator removeFromSuperview];
    [activityIndicator release];
    activityIndicator = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [Common isSupportedOrientation:interfaceOrientation];
}

@end
