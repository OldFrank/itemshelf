// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "Common.h"

/**
   Called when assertion failed from ASSERT macro.
*/
void AssertFailed(const char *filename, int line)
{
    NSLog(@"Assertion failed: %s line %d", filename, line);
    UIAlertView *v = [[UIAlertView alloc]
                         initWithTitle:@"Assertion Failed"
                         message:[NSString stringWithFormat:@"%s line %d", filename, line]
                         delegate:nil
                         cancelButtonTitle:@"Close"
                         otherButtonTitles:nil];
    [v show];
    [v release];
}

@implementation Common
/*
  - (id)init
  {
  self = [super init];
  return self;
  }
*/

/**
   @brief Show alert dialog
   @param[in] title Dialog title
   @param[in] message Dialog message
*/
+ (void)showAlertDialog:(NSString*)title message:(NSString*)message
{
    UIAlertView *av = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(title, @"")
                          message:NSLocalizedString(message, @"") 
                          delegate:nil 
                          cancelButtonTitle:NSLocalizedString(@"Close", @"") 
                          otherButtonTitles:nil];
    [av show];
    [av release];
}

/**
   @brief Resize UIImage to fit in speficied size
*/
+ (UIImage *)resizeImageWithin:(UIImage *)image width:(double)maxWidth height:(double)maxHeight
{
    double ratio = 1.0;
    double width = image.size.width;
    double height = image.size.height;
	
    if (height > maxHeight) {
        ratio = maxHeight / height;
    }
    if (width > maxWidth) {
        double r = maxWidth / width;
        if (r < ratio) {
            ratio = r;
        }
    }
	
    if (ratio == 1.0) {
        return image; // do nothing
    }
    width = (int)(width * ratio);
    height = (int)(height * ratio);
	
    return [Common resizeImage:image width:width height:height];
}

/**
   @brief Resize image with specified size
*/
+ (UIImage *)resizeImage:(UIImage *)image width:(double)width height:(double)height
{
    //	return [image _imageScaledToSize:CGSizeMake(width, height) interpolationQuality:0];
	
    CGSize newSize = CGSizeMake(width, height);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

/**
   @brief Conver currency string
*/
+ (NSString *)currencyString:(double)value withLocaleString:(NSString *)locale
{
    static NSNumberFormatter *nf = nil;

    if (nf == nil) {
        nf = [[NSNumberFormatter alloc] init];
        [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    }

    if (locale == nil) {
        [nf setLocale:[NSLocale currentLocale]];
    } else {
        NSLocale *loc = [[NSLocale alloc] initWithLocaleIdentifier:locale];
        [nf setLocale:loc];
        [loc release];
    }
    NSString *ret = [nf stringFromNumber:[NSNumber numberWithDouble:value]];

    return ret;
}

+ (BOOL)isSupportedOrientation:(UIInterfaceOrientation)orientation
{
    if (IS_IPAD) return YES;
    return (orientation == UIInterfaceOrientationPortrait);
}


@end

@implementation UIViewController (MyExt)

/**
   @brief Show modal view with navigation controller

   @param[in] vc View controller to show modal.
*/
- (void)doModalWithNavigationController:(UIViewController *)vc
{
    UINavigationController *newnv = [[UINavigationController alloc]
                                        initWithRootViewController:vc];

    if (IS_IPAD) {
        newnv.modalPresentationStyle = UIModalPresentationPageSheet;
    }
    [self.navigationController presentModalViewController:newnv animated:YES];
    [newnv release];
}

static UIPopoverController *_commonPopover = nil;

- (void)doModalWithPopoverController:(UIViewController *)vc fromBarButtonItem:(UIBarButtonItem *)barButton
{
    if (_commonPopover) {
        [self dismissModalPopover];
    }

    _commonPopover = [[UIPopoverController alloc] initWithContentViewController:vc];
    [_commonPopover presentPopoverFromBarButtonItem:barButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)dismissModalPopover
{
    if (_commonPopover != nil) {
        [_commonPopover dismissPopoverAnimated:YES];
        [_commonPopover release];
        _commonPopover = nil;
    }
}

@end

/**
   Extended UIButton
*/
@implementation UIButton (MyExt)

- (void)setTitleForAllState:(NSString*)title
{
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateHighlighted];
    [self setTitle:title forState:UIControlStateDisabled];
    [self setTitle:title forState:UIControlStateSelected];
}

@end

/**
   Extended String
*/
@implementation NSString (MyExt)

- (NSMutableArray *)splitWithDelimiter:(NSString*)delimiter
{
    NSMutableArray *ary = [[[NSMutableArray alloc] initWithCapacity:3] autorelease];

    NSScanner *scanner = [NSScanner scannerWithString:self];
    NSCharacterSet *delimiterSet = [NSCharacterSet characterSetWithCharactersInString:delimiter];
    NSString *token;

    while (![scanner isAtEnd]) {
        // find token;
        if ([scanner scanUpToCharactersFromSet:delimiterSet intoString:&token]) {
            token = [token stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (token.length > 0) {
                [ary addObject:token];
            }
        }

        // skip delimiters
        [scanner scanCharactersFromSet:delimiterSet intoString:nil];
    }
    return ary;
}
@end
