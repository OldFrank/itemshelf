// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <AudioToolbox/AudioToolbox.h>

#import "NumPadViewController.h"
#import "AppDelegate.h"
#import "SearchController.h"

@implementation NumPadViewController

@synthesize selectedShelf;

+ (NumPadViewController *)numPadViewController:(NSString*)title
{
    NSString *nibName;
    if (IS_IPAD) {
        nibName = @"NumPadView-iPad";
    } else {
        nibName = @"NumPadView";
    }
    NumPadViewController *vc = [[[NumPadViewController alloc]
                                    initWithNibName:nibName
                                    bundle:nil] autorelease];
    vc.title = title;
    return vc;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    self = [super initWithNibName:nibName bundle:bundle];
    if (self) {
        webApiFactory = [[WebApiFactory alloc] init];
        [webApiFactory setCodeSearch];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    textField.placeholder = self.title;
    textField.clearButtonMode = UITextFieldViewModeAlways;
	
    noteLabel.text = NSLocalizedString(@"NumPadNoteText", @"");
	
    // set service string
    [serviceIdButton setTitleForAllState:[webApiFactory serviceIdString]];

    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
												 initWithTitle:@"Search" style:UIBarButtonItemStyleDone
											     target:self action:@selector(doneAction:)] autorelease];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
                                                 initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                 target:self
                                                 action:@selector(cancelAction:)] autorelease];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [webApiFactory release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [textField resignFirstResponder];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (IBAction)padTapped:(id)sender
{
    // ボタンクリック音を鳴らす
    AudioServicesPlaySystemSound(1105);
	
    UIButton *button = sender;
    NSString *s = button.currentTitle;
    LOG(@"%@", s);
	
    NSString *t = textField.text;
    NSString *newtext = nil;
	
    if ([s isEqualToString:@"⌫"]) {
        if (t != nil && t.length > 0) {
            newtext = [t substringToIndex:t.length - 1];			
        }
    } else {
        if (t == nil) {
            newtext = s;
        } else {
            newtext = [t stringByAppendingString:s];
        }
    }
    textField.text = newtext;
}

// return キーを押したときにキーボードを消すための処理
- (BOOL)textFieldShouldReturn:(UITextField*)t
{
    [t resignFirstResponder];
    return YES;
}

- (IBAction)doneAction:(id)sender
{
    if (textField.text.length < 8) {
        [Common showAlertDialog:@"Error" message:@"Code is too short"];
        return;
    }
	
    [textField resignFirstResponder];


    SearchController *sc = [SearchController newController];
    sc.delegate = self;
    sc.viewController = self;
    sc.selectedShelf = selectedShelf;

    WebApi *api = [webApiFactory allocWebApi];
    [sc search:api withCode:textField.text];
    [api release];
}

- (void)searchControllerFinish:(SearchController*)sc result:(BOOL)result
{
    if (result) {
        textField.text = nil;
    }
}

- (IBAction)cancelAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)serviceIdButtonTapped:(id)sender
{
    GenSelectListViewController *vc =
        [GenSelectListViewController
            genSelectListViewController:self
            array:[webApiFactory serviceIdStrings]
            title:NSLocalizedString(@"Select locale", @"")];
    vc.selectedIndex = webApiFactory.serviceId;
	
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)genSelectListViewChanged:(GenSelectListViewController*)vc
{
    webApiFactory.serviceId = vc.selectedIndex;
    [webApiFactory saveDefaults];
    [serviceIdButton setTitleForAllState:[webApiFactory serviceIdString]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [Common isSupportedOrientation:interfaceOrientation];
}

@end
