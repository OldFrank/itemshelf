// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "Common.h"
#import "Item.h"
#import "GenSelectListViewController.h"
#import "EditTagsViewController.h"
#import "EditMemoVC.h"
#import "EditStarViewController.h"
#import "GenEditTextViewController.h"

@interface ItemViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, ItemDelegate, 
     EditTagsViewDelegate, EditMemoViewDelegate, EditStarViewDelegate,
     GenSelectListViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,
     GenEditTextViewDelegate, MFMailComposeViewControllerDelegate>
{
    IBOutlet UITableView *tableView;
    IBOutlet UIBarButtonItem *cameraButton;
	
    NSMutableArray *itemArray;
    NSString *urlString;

    UIActionSheet *openActionSheet;
    UIActionSheet *cameraActionSheet;

    Item *currentEditingItem;
    int currentEditingRow;
    
    // iPad
    UIPopoverController *popoverController;
}

@property(nonatomic,retain) NSMutableArray *itemArray;
@property(nonatomic,retain) NSString *urlString;


- (IBAction)cameraButtonTapped:(id)sender;
- (void)execImagePicker:(UIImagePickerControllerSourceType)sourceType;
//- (IBAction)moveActionButtonTapped:(id)sender;
- (IBAction)openActionButtonTapped:(id)sender;
- (void)sendMail;
- (void)openSafari;

// private method
//- (void)updateInfoStringsDict;
//- (NSMutableArray *)infoStrings:(int)index;

- (int)_calcRowKind:(NSIndexPath *)indexPath item:(Item *)item;

//- (void)checkAndAppendString:(NSMutableArray*)infoStrings value:(NSString *)value withName:(NSString *)name;
- (UITableViewCell *)getImageCell:(UITableView *)tv item:(Item*)item;

@end
