// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AppDelegate.h"
#import "ScanViewController.h"
#import "ItemViewController.h"
//#import "BarcodeReader.h"
#import "NumPadViewController.h"
#import "DataModel.h"
#import "SearchController.h"
#import "WebApi.h"

@implementation ScanViewController
@synthesize selectedShelf;

static UIImage *cameraIcon = nil, *libraryIcon = nil, *numpadIcon = nil, *keywordIcon = nil, *localeIcon = nil;

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.navigationItem.title = NSLocalizedString(@"Scan", @"");
	
    self.tableView.rowHeight = 70; // TBD

    activityIndicator = nil;

    if (cameraIcon == nil) {
        cameraIcon  = [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ScanCamera" ofType:@"png"]] retain];
        libraryIcon = [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PhotoLibrary" ofType:@"png"]] retain];
        numpadIcon  = [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NumPad" ofType:@"png"]] retain];
        keywordIcon = [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"EnterCode" ofType:@"png"]] retain];
        localeIcon  = [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Locale" ofType:@"png"]] retain];
    }
	
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
                                                 initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                 target:self
                                                 action:@selector(doneAction:)] autorelease];
    
    isCameraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (void)doneAction:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [AppDelegate reload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
    [selectedShelf release];
    if (mPopoverController != nil) {
        [mPopoverController dismissPopoverAnimated:YES];
        [mPopoverController release];
    }

    [super dealloc];
}


////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!isCameraAvailable) {
        return 5;
    }
    return 6;
}

// セルを返す
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#define SCAN_CELL_ID @"ScanViewCellId"
#define TAG_IMAGE 1
#define TAG_NAME 2
#define TAG_DESC 3

    UIImageView *imgView;
    UILabel *nameLabel, *descLabel;
	
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:SCAN_CELL_ID];

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SCAN_CELL_ID] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    // アイコン
    imgView = cell.imageView;
    imgView.contentMode = UIViewContentModeScaleAspectFit; // 画像のアスペクト比を変えないようにする。

    nameLabel = cell.textLabel;
    descLabel = cell.detailTextLabel;
    descLabel.font = [UIFont systemFontOfSize:10.0];
    descLabel.lineBreakMode = UILineBreakModeWordWrap;

    int row = indexPath.row;
    if (!isCameraAvailable) {
        row++;
    }
    
    switch (row) {
    case 0:
        imgView.image = cameraIcon;
        nameLabel.text = NSLocalizedString(@"Camera scan", @"");
        descLabel.text = NSLocalizedString(@"Scan barcode with iPhone's camera", @"");
        break;
    case 1:
        imgView.image = libraryIcon;
        nameLabel.text = NSLocalizedString(@"Photo library scan", @"");
        descLabel.text = NSLocalizedString(@"Scan barcode image from photo library", @"");
        break;
    case 2:
        imgView.image = numpadIcon;
        nameLabel.text = NSLocalizedString(@"Enter item code", @"");
        descLabel.text = NSLocalizedString(@"EnterCodeDescription", @"");
        break;
    case 3:
        imgView.image = keywordIcon;
        nameLabel.text = NSLocalizedString(@"Enter title", @"");
        descLabel.text = NSLocalizedString(@"EnterTitleDescription", @"");
        break;
    case 4:
        imgView.image = keywordIcon;
        nameLabel.text = NSLocalizedString(@"Manual input", @"");
        descLabel.text = NSLocalizedString(@"ManualInputDescription", @"");
        break;
    case 5:
        imgView.image = localeIcon;
        nameLabel.text = NSLocalizedString(@"Select locale", @"");
        descLabel.text = NSLocalizedString(@"Select locale of service", @"");
        break;
    }
	
    return cell;
}

// セルをクリックしたときの処理
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath:indexPath animated:NO];
	
    int row = indexPath.row;
    if (!isCameraAvailable) {
        row++;
    }
    
    switch (row) {
    case 0:
        [self scanWithCamera:nil];
        break;
    case 1:
        [self scanFromLibrary:nil];
        break;
    case 2:
        [self enterIdentifier:nil];
        break;
    case 3:
        [self enterKeyword:nil];
        break;
    case 4:
        [self enterManual:nil];
        break;
    case 5:
        [self selectService];
        break;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////
// 画像取り込み処理

#pragma mark - Scan

- (IBAction)scanWithCamera:(id)sender
{
    if (!isCameraAvailable) {
        // abort
        // TBD
        return;
    }
	
    // for iOS 3.x
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0) {
        [self scanWithImagePicker:UIImagePickerControllerSourceTypeCamera];
        return;
    }

    // iOS 4.x
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    
    ZBarImageScanner *scanner = reader.scanner;
    
    [scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    
    [self presentModalViewController:reader animated:YES];
    [reader release];
}

- (IBAction)scanFromLibrary:(id)sender
{
    [self scanWithImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL)scanWithImagePicker:(UIImagePickerControllerSourceType)type
{
    if (![UIImagePickerController isSourceTypeAvailable:type]) {
        // abort
        // TBD
        return NO;
    }
	
    ZBarReaderController *reader = [ZBarReaderController new];
    reader.readerDelegate = self;
    reader.sourceType = type;
    if (IS_IPAD) {
        // iPad の場合は、popover で表示する必要がある
        if (mPopoverController != nil) {
            [mPopoverController dismissPopoverAnimated:YES];
            [mPopoverController release];
        }
        mPopoverController = [[UIPopoverController alloc] initWithContentViewController:reader];
        NSIndexPath *idx = [NSIndexPath indexPathForRow:0 inSection:0];
        [mPopoverController
            presentPopoverFromRect:[self.tableView cellForRowAtIndexPath:idx].frame
                            inView:self.tableView
          permittedArrowDirections:UIPopoverArrowDirectionAny
                          animated:YES];
    } else {
        [self presentModalViewController:reader animated:YES];
    }
    [reader release];
    return YES;
}

#pragma mark - UIImagePickerControllerDelegate

// ZBarReader 認識完了
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
    if (results != nil) {
        // ZBar 認識完了
        ZBarSymbol *symbol = nil;

        NSString *code = nil;
        for (symbol in results) {
            code = symbol.data;
            NSLog(@"Code = %@", code);
            if ([code hasPrefix:@"97"]) {
                // may be ISBN
                break;
            }
        }

        // dismiss controller
        [picker dismissModalViewControllerAnimated:YES];

        // pass result
        [self _didRecognizeBarcode:code];
    }
}

// バーコード解析完了 → 検索開始
- (void)_didRecognizeBarcode:(NSString*)code
{
    WebApiFactory *wf = [WebApiFactory webApiFactory];
    [wf setCodeSearch];
    WebApi *api = [wf allocWebApi];
    
    SearchController *sc = [SearchController newController];
    sc.delegate = self;
    sc.viewController = self;
    sc.selectedShelf = selectedShelf;
    [sc search:api withCode:code];
    [api release];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
}

#pragma mark - SearchControllerDelegate

- (void)searchControllerFinish:(SearchController*)controller result:(BOOL)result
{
    // TBD : 再度開始する？？？
}


////////////////////////////////////////////////////////////////////////////////////////////
// マニュアル入力処理

#pragma mark - Manual input

// コード入力
- (void)enterIdentifier:(id)sender
{
    NumPadViewController *v = [NumPadViewController numPadViewController:NSLocalizedString(@"Code", @"")];
    v.selectedShelf = selectedShelf;

    [self.navigationController pushViewController:v animated:YES];
}

// タイトル入力
- (void)enterKeyword:(id)sender
{
    KeywordViewController2 *v = [KeywordViewController2 keywordViewController:NSLocalizedString(@"Keyword", @"")];
    v.selectedShelf = selectedShelf;

    [self.navigationController pushViewController:v animated:YES];
}

////////////////////////////////////////////////////////////////////////////////////////////
// 手動入力
- (void)enterManual:(id)sender
{
    Item *item = [[[Item alloc] init] autorelease];
    if (selectedShelf == nil) {
        item.shelfId = 0; // 未分類
    } else {
        item.shelfId = selectedShelf.pid;
    }
    DataModel *dm = [DataModel sharedDataModel];
    [dm addItem:item];

    NSMutableArray *itemArray = [[[NSMutableArray alloc] init] autorelease];
    [itemArray addObject:item];

    // show item view
    NSString *nib = (IS_IPAD) ? @"ItemView-ipad" : @"ItemView";
    ItemViewController *vc = [[[ItemViewController alloc] initWithNibName:nib bundle:nil] autorelease];
    vc.itemArray = itemArray;

    [self.navigationController pushViewController:vc animated:YES];
}

////////////////////////////////////////////////////////////////////////////////////////////
// サービス選択

#pragma mark - Service selection

- (void)selectService
{
    WebApiFactory *wf = [WebApiFactory webApiFactory];
    NSArray *services = [wf serviceIdStrings];
	
    GenSelectListViewController *vc =
        [GenSelectListViewController
            genSelectListViewController:self
            array:services
            title:NSLocalizedString(@"Select locale", @"")];
    vc.selectedIndex = wf.serviceId;
	
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)genSelectListViewChanged:(GenSelectListViewController*)vc
{
    int serviceId = [vc selectedIndex];

    WebApiFactory *wf = [WebApiFactory webApiFactory];
    wf.serviceId = serviceId;
    [wf saveDefaults];
}

#pragma mark - rotation etc

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [Common isSupportedOrientation:interfaceOrientation];
}

@end
