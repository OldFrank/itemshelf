// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class GenEditTextViewController;

@protocol GenEditTextViewDelegate
- (void)genEditTextViewChanged:(GenEditTextViewController *)vc;
@end

@interface GenEditTextViewController : UIViewController <UITextViewDelegate> {
    IBOutlet UITextField *textField;
	
    id<GenEditTextViewDelegate> delegate;
    NSString *text;
    int identifier;
}

@property(nonatomic,assign) id<GenEditTextViewDelegate> delegate;
@property(nonatomic,assign) int identifier;
@property(nonatomic,retain) NSString *text;

+ (GenEditTextViewController *)genEditTextViewController:(id<GenEditTextViewDelegate>)delegate title:(NSString*)title;
- (void)doneAction;

@end
