// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// テキスト入力フィールドを１個だけもつ汎用のビューコントローラ

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Common.h"
#import "GenSelectListViewController.h"
#import "Shelf.h"
#import "SearchController.h"

@class KeywordViewController;

@interface KeywordViewController2 : UIViewController
<GenSelectListViewDelegate, SearchControllerDelegate, UITextFieldDelegate>
{
    IBOutlet UITableView *tableView;
    UITextField *textField;

    NSString *initialText;
    Shelf *selectedShelf;

    int searchSelectedIndex;
    NSArray *searchIndices;
    
    SearchKeyType searchKeyType;
    NSArray *searchKeyTypes;

    WebApiFactory *webApiFactory;
}

@property(nonatomic,assign) Shelf *selectedShelf;
@property(nonatomic,retain) NSString *initialText;

+ (KeywordViewController2 *)keywordViewController:(NSString*)title;
- (void)_setupCategories;
- (IBAction)doneAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

- (UITableViewCell *)containerCellWithTitle:(NSString*)title view:(UIView *)view;
- (UITableViewCell *)containerCellWithTitle:(NSString*)title text:(NSString *)text;

@end

@interface KeywordViewCell : UITableViewCell
{
    UIView *attachedView;
}

+ (KeywordViewCell *)getCell:(NSString *)title tableView:(UITableView*)tableView identifier:(NSString *)identifier;
- (void)attachView:(UIView *)view;
@end
