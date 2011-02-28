// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
  ItemShelf for iPhone/iPod touch

  Copyright (c) 2008, ItemShelf Development Team. All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer. 

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution. 

  3. Neither the name of the project nor the names of its contributors
  may be used to endorse or promote products derived from this software
  without specific prior written permission. 

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "AppDelegate.h"
#import "ScanViewController.h"
#import "ItemViewController.h"
#import "BarcodeReader.h"
#import "BarcodeScannerController2.h"
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

    [super dealloc];
}


////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (IS_IPAD) {
        return 4; // no camera, no photo library
    }
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
#if 1
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

#else
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SCAN_CELL_ID] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        // アイコン
        imgView = [[[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 58, 58)] autorelease];
        imgView.tag = TAG_IMAGE;
        imgView.autoresizingMask = 0;
        imgView.contentMode = UIViewContentModeScaleAspectFit; // 画像のアスペクト比を変えないようにする。
        [cell.contentView addSubview:imgView];
		
        // 名称
        nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(70, 10, 240, 18)] autorelease];
        nameLabel.tag = TAG_NAME;
        nameLabel.font = [UIFont boldSystemFontOfSize:14.0];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [cell.contentView addSubview:nameLabel];

        // 説明
        descLabel = [[[UILabel alloc] initWithFrame:CGRectMake(70, 30, 240, 30)] autorelease];
        descLabel.tag = TAG_DESC;
        descLabel.font = [UIFont systemFontOfSize:12.0];
        descLabel.textColor = [UIColor grayColor];
        descLabel.backgroundColor = [UIColor clearColor];
        descLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        descLabel.lineBreakMode = UILineBreakModeWordWrap;
        descLabel.numberOfLines = 0;
        descLabel.contentMode = UIViewContentModeTop;
        [cell.contentView addSubview:descLabel];
    } else {
        imgView = (UIImageView *)[cell.contentView viewWithTag:TAG_IMAGE];
        nameLabel = (UILabel *)[cell.contentView viewWithTag:TAG_NAME];
        descLabel = (UILabel *)[cell.contentView viewWithTag:TAG_DESC];
    }		
#endif

    int row = indexPath.row;
    if (IS_IPAD) {
        row+=2;
    } else if (!isCameraAvailable) {
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
    if (IS_IPAD) {
        row += 2;
    } else if (!isCameraAvailable) {
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

- (IBAction)scanWithCamera:(id)sender
{
    if (!isCameraAvailable) {
        // abort
        // TBD
        return;
    }
	
    // for iOS 3.x
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0) {
        [self scanFromLibrary:UIImagePickerControllerSourceTypeCamera];
        return;
    }

    // iOS 4.x
    BarcodeScannerController2 *scanner = [[[BarcodeScannerController alloc] init] autorelease];
    scanner.delegate = self;
    [self presentModalViewController:scanner animated:YES];
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
	
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = type;
    picker.delegate = self;
    picker.allowsEditing = YES;
	
    [self presentModalViewController:picker animated:YES];
    [picker release];
    return YES;
}

#pragma mark BarcodeScannerControllerDelegate

- (void)barcodeScannerController:(BarcodeScannerController*)scanner didRecognizeBarcode:(NSString*)code
{
    [[scanner parentViewController] dismissModalViewControllerAnimated:YES];
    [self _didRecognizeBarcode:code];
}

#pragma mark UIImagePickerControllerDelegate

// 画像取得完了
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];

    [[picker parentViewController] dismissModalViewControllerAnimated:YES];

    // バーコード解析
    BarcodeReader *reader = [[[BarcodeReader alloc] init] autorelease];
    if (![reader recognize:image]) {
        [Common showAlertDialog:@"No symbol" message:@"Could not recognize barcode symbol"];
        return;
    }

    [self _didRecognizeBarcode:reader.data];
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

#pragma mark SearchControllerDelegate

- (void)searchControllerFinish:(SearchController*)controller result:(BOOL)result
{
    // TBD : 再度開始する？？？
}


////////////////////////////////////////////////////////////////////////////////////////////
// マニュアル入力処理

#pragma mark -

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
        item.shelfId = selectedShelf.pkey;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [Common isSupportedOrientation:interfaceOrientation];
}

@end
