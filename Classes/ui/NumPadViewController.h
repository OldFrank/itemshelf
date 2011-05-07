// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Common.h"
#import "Shelf.h"
#import "SearchController.h"
#import "GenSelectListViewController.h"

@class NumPadViewController;

@interface NumPadViewController : UIViewController <SearchControllerDelegate, GenSelectListViewDelegate> {
    IBOutlet UITextField *textField;
    IBOutlet UILabel *noteLabel;
    IBOutlet UIButton *serviceIdButton;

    Shelf *selectedShelf;
    WebApiFactory *webApiFactory;
}

@property(nonatomic,assign) Shelf *selectedShelf;

+ (NumPadViewController *)numPadViewController:(NSString*)title;
- (IBAction)padTapped:(id)sender;
- (IBAction)doneAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)serviceIdButtonTapped:(id)sender;

@end
