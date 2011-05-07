// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "GenEditTextViewController.h"
#import "AppDelegate.h"

@implementation GenEditTextViewController

@synthesize delegate, identifier, text;

+ (GenEditTextViewController *)genEditTextViewController:(id<GenEditTextViewDelegate>)delegate title:(NSString*)title
{
    GenEditTextViewController *vc = [[[GenEditTextViewController alloc]
                                         initWithNibName:@"GenEditTextView"
                                         bundle:[NSBundle mainBundle]] autorelease];
    vc.delegate = delegate;
    vc.title = title;
    vc.identifier = -1;

    return vc;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    textField.placeholder = self.title;
	
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(doneAction)] autorelease];
}

- (void)dealloc {
    [text release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    textField.text = text;
    [textField becomeFirstResponder];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)doneAction
{
    self.text = textField.text;
    [delegate genEditTextViewChanged:self];

    [self.navigationController popViewControllerAnimated:YES];
}

// UITextViewDelegate
- (BOOL)textFieldShouldReturn:(UITextView *)v
{
    [self doneAction];
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [Common isSupportedOrientation:interfaceOrientation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

@end
