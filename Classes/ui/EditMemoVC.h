// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class EditMemoViewController;

@protocol EditMemoViewDelegate
- (void)editMemoViewChanged:(EditMemoViewController *)vc identifier:(int)id;
@end

@interface EditMemoViewController : UIViewController {
    IBOutlet UITextView *textView;
	
    id<EditMemoViewDelegate> delegate;
    NSString *text;
    int identifier;
    
    BOOL keyboardShown;
}

@property(nonatomic,assign) id<EditMemoViewDelegate> delegate;
@property(nonatomic,assign) int identifier;
@property(nonatomic,retain) NSString *text;

+ (EditMemoViewController *)editMemoViewController:(id<EditMemoViewDelegate>)delegate title:(NSString*)title identifier:(int)id;
- (void)doneAction;

- (void)onKeyboardShown:(NSNotification *)notification;
- (void)onKeyboardHidden:(NSNotification *)notification;
- (void)_keyboardShownHidden:(NSNotification *)notification isShown:(BOOL)isShown;

@end
