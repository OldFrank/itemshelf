// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// 共通

#ifdef DEBUG
#define LOG(...) NSLog(__VA_ARGS__)
#define ASSERT(x) if (!(x)) AssertFailed(__FILE__, __LINE__)
void AssertFailed(const char *filename, int line);

#else
#define	LOG(...)  /**/
#define ASSERT(x) /**/
#endif

#import "StringArray.h"

// Utility
#ifndef UI_USER_INTERFACE_IDIOM
#define IS_IPAD NO
#else
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#endif

/**
   Common utility class
 */
@interface Common : NSObject {
}

+ (void)showAlertDialog:(NSString*)title message:(NSString*)message;
+ (UIImage *)resizeImageWithin:(UIImage *)image width:(double)maxWidth height:(double)maxHeight;
+ (UIImage *)resizeImage:(UIImage *)image width:(double)width height:(double)height;
+ (NSString *)currencyString:(double)value withLocaleString:(NSString *)locale;
+ (BOOL)isSupportedOrientation:(UIInterfaceOrientation)orientation;
@end

/**
   Extended UIViewController
*/
@interface UIViewController (MyExt)
- (void)doModalWithNavigationController:(UIViewController *)vc;
- (void)doModalWithPopoverController:(UIViewController *)vc fromBarButtonItem:(UIBarButtonItem *)barButton;
- (void)dismissModalPopover;
@end

/**
   Extended UIButton
*/
@interface UIButton (MyExt)
- (void)setTitleForAllState:(NSString*)title;
@end

/**
   Extended string
*/
@interface NSString (MyExt)
- (NSMutableArray *)splitWithDelimiter:(NSString*)delimiters;
@end
