// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "EditMemoVC.h"
#import "AppDelegate.h"

@implementation EditMemoViewController

@synthesize delegate, identifier, text;

+ (EditMemoViewController *)editMemoViewController:(id<EditMemoViewDelegate>)delegate title:(NSString*)title identifier:(int)id
{
    EditMemoViewController *vc = [[[EditMemoViewController alloc]
                                      initWithNibName:@"EditMemoView"
                                      bundle:[NSBundle mainBundle]] autorelease];
    vc.delegate = delegate;
    vc.title = title;
    vc.identifier = id;

    return vc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //textView.placeholder = self.title;
    textView.backgroundColor = [UIColor whiteColor];
	
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(doneAction)] autorelease];

    // keyboard notification
    keyboardShown = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardHidden:)
                                                 name:UIKeyboardDidHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [text release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    textView.text = text;
    [textView becomeFirstResponder];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)doneAction
{
    self.text = textView.text;
    [delegate editMemoViewChanged:self identifier:identifier];

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark keyboardEvent

- (void)onKeyboardShown:(NSNotification *)notification
{
    [self _keyboardShownHidden:notification isShown:YES];
}

- (void)onKeyboardHidden:(NSNotification *)notification
{
    [self _keyboardShownHidden:notification isShown:NO];
}

- (void)_keyboardShownHidden:(NSNotification *)notification isShown:(BOOL)isShown
{
    if (keyboardShown == isShown) return;
    keyboardShown = isShown;
    
    NSDictionary *info = [notification userInfo];
    
    // キーボードサイズ取得
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardEndFrame = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    
    // textView サイズ変更
    CGRect frame = textView.frame;
    if (isShown) {
        frame.size.height -= keyboardFrame.size.height;
    } else {
        frame.size.height += keyboardFrame.size.height;
    }
    textView.frame = frame;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [Common isSupportedOrientation:interfaceOrientation];
}

@end
