// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "Common.h"

@interface WebViewController : UIViewController 
<UIWebViewDelegate>
{
    IBOutlet UIWebView *webView;
    IBOutlet UIBarButtonItem *barButtonForward;
    IBOutlet UIBarButtonItem *barButtonBack;
	
    NSString *urlString;
    UIActivityIndicatorView *activityIndicator;
}

@property(nonatomic,retain) UIWebView *webView;
@property(nonatomic,retain) NSString *urlString;

- (IBAction)goForward:(id)sender;
- (IBAction)goBackward:(id)sender;
- (IBAction)reloadPage:(id)sender;

@end
