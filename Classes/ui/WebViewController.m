// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "WebViewController.h"
#import "Item.h"

@implementation WebViewController
@synthesize webView, urlString;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    self = [super initWithNibName:nibName bundle:bundle];
    if (self) {
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.title = NSLocalizedString(@"Browser", @"");

    barButtonBack.enabled = NO;
    barButtonForward.enabled = NO;
	
    // activity indicator を作る
    activityIndicator = [[UIActivityIndicatorView alloc]
                            initWithFrame:CGRectMake(0, 0, 32, 32)];
    activityIndicator.center = CGPointMake(160, 208);

    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    activityIndicator.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin | 
        UIViewAutoresizingFlexibleTopMargin | 
        UIViewAutoresizingFlexibleBottomMargin;
	
    [self.view addSubview:activityIndicator];
    [activityIndicator release];

    [activityIndicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didReceiveMemoryWarning {
    [Item clearAllImageCache];
    //[super didReceiveMemoryWarning];
}

- (void)dealloc {
    // webView の解放前に delegate をリセットしなければならない
    // (UIWebViewDelegate のリファレンス参照)
    webView.delegate = nil;
    [webView release];
    
    [urlString release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    // メモリを空けておく
    [Item clearAllImageCache];

    // ページロード処理
    //NSLog(@"Open URL: %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *req = [[[NSURLRequest alloc] initWithURL:url] autorelease];
    [webView loadRequest:req];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [webView stopLoading];
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [Common isSupportedOrientation:interfaceOrientation];
}

- (IBAction)goForward:(id)sender
{
    [webView goForward];
}

- (IBAction)goBackward:(id)sender
{
    [webView goBack];
}

- (IBAction)reloadPage:(id)sender
{
    [webView reload];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orient duration:(NSTimeInterval)duration
{
#if 0
    if (orient != UIInterfaceOrientationPortrait) {
        self.navigationController.navigationBarHidden = YES;
    }
#endif
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orient
{
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
        self.navigationController.navigationBarHidden = NO;
    } else {
        self.navigationController.navigationBarHidden = YES;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////
// UIWebViewDelegate

- (BOOL)webView:(UIWebView *)v shouldStartLoadWithReq:(NSURLRequest *)req
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [activityIndicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)v
{
    [activityIndicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
    barButtonBack.enabled = [v canGoBack];
    barButtonForward.enabled = [v canGoForward];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError*)err
{
    [activityIndicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    [Common showAlertDialog:@"Error" message:NSLocalizedString(@"Cannot connect with service", @"")];
}

////////////////////////////////////////////////////////////////////////////////////////////

@end
