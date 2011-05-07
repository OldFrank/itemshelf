// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "Common.h"
#import "Shelf.h"
#import "EditTagsViewController.h"
#import "EditStarViewController.h"

@interface EditShelfViewController : UITableViewController
<UITextFieldDelegate, EditTagsViewDelegate, EditStarViewDelegate>
{
    Shelf *shelf;
    BOOL isNew;

    UITextField *shelfNameField;
    UITextField *titleField;
    UITextField *authorField;
    UITextField *manufacturerField;
    UILabel *tagsField;
    UILabel *starField;
    int starFilter;
}

@property(nonatomic,retain) Shelf *shelf;
@property(nonatomic,assign) BOOL isNew;

+ (EditShelfViewController *)editShelfViewController:(Shelf *)shelf isNew:(BOOL)isNew;

// private
- (void)doneAction:(id)sender;
- (void)closeAction:(id)sender;
- (UITextField*)allocTextInputField:(NSString*)value placeholder:(NSString*)placeholder;
- (UILabel*)allocTextLabelField:(NSString*)value;
- (UITableViewCell *)textViewCell:(NSString *)title view:(UIView *)view;
- (NSString *)_starFilterString:(int)starFilter;

@end
