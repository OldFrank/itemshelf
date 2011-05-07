// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// Scan ビューコントローラ

#import <UIKit/UIKit.h>

#import "ZBarSDK.h"

#import "Common.h"
#import "GenSelectListViewController.h"
#import "NumPadViewController.h"
//#import "KeywordViewController.h"
#import "KeywordViewController2.h"
#import "Shelf.h"
#import "SearchController.h"

@interface ScanViewController : UITableViewController 
<UIImagePickerControllerDelegate, UINavigationControllerDelegate,
GenSelectListViewDelegate, SearchControllerDelegate,
ZBarReaderDelegate>
{
    UIActivityIndicatorView *activityIndicator;
    Shelf *selectedShelf;
	
    BOOL autoRegisterShelf;
    BOOL isCameraAvailable;
    
    UIPopoverController *mPopoverController;
}

@property(nonatomic,retain) Shelf *selectedShelf;

- (void)doneAction:(id)sender;

- (IBAction)scanWithCamera:(id)sender;
- (IBAction)scanFromLibrary:(id)sender;
- (BOOL)scanWithImagePicker:(UIImagePickerControllerSourceType)type;
- (void)enterIdentifier:(id)sender;
- (void)enterKeyword:(id)sender;
- (void)enterManual:(id)sender;

//- (BOOL)execScan:(UIImagePickerControllerSourceType)type;
- (void)selectService;

- (void)_didRecognizeBarcode:(NSString*)code;

@end
