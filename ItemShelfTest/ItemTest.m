// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestUtility.h"

@interface ItemTest : SenTestCase {
    Database *db;
}

- (void)assertItemEquals:(Item *)i with:(Item *)j;

@end


@implementation ItemTest

- (void)setUp
{
    db = [Database instance];
}

- (void)tearDown
{
}

// テーブルがないときにテーブルが作成されること
- (void)testInitDb
{
    // テーブルを削除する
    [db exec:@"DROP TABLE Item;"];
    [Database shutdown];

    // 再度オープンする (ここでテーブルができるはず）
    [[DataModel sharedDataModel] loadDB];
    db = [Database instance];
    
    dbstmt *stmt = [db prepare:@"SELECT sql FROM sqlite_master WHERE type='table' AND name='Item';"];
    STAssertEquals(SQLITE_ROW, [stmt step], @"No item table");
    NSString *sql = [stmt colString:0];

    // TBD: ここでテーブル定義をチェック

}

// テーブルのアップグレードテスト
// ver 1.0 からのアップグレードはまだないので、テスト不要

// Utility : Item の同一性確認
- (void)assertItemEquals:(Item *)i with:(Item *)j
{
    AssertEqualInt(j.pid, i.pid);
    AssertEqualInt(j.shelfId, i.shelfId);
    AssertEqualInt(j.serviceId, i.serviceId);
    AssertEqualInt(j.sorder, i.sorder);
    Assert([i.date isEqualToDate:j.date]);
    AssertEqualString(j.idString, i.idString);
    AssertEqualString(j.asin, i.asin);
    AssertEqualString(j.name, i.name);
    AssertEqualString(j.author, i.author);
    AssertEqualString(j.manufacturer, i.manufacturer);
    AssertEqualString(j.category, i.category);
    AssertEqualString(j.detailURL, i.detailURL);
    AssertEqualString(j.price, i.price);
    AssertEqualString(j.tags, i.tags);
    AssertEqualString(j.memo, i.memo);
    AssertEqualString(j.imageURL, i.imageURL);
}

#pragma mark - Fundamental tests

// initialize test
- (void)testInitItem
{
    Item *item = [[Item new] autorelease];
    AssertNotNil(item.date);
    Assert([item.date isKindOfClass:[NSDate class]]);
    AssertEqualInt(0, item.shelfId);
    AssertEqualInt(-1, item.sorder);
    AssertEqualInt(0, item.star);
    AssertFalse(item.registeredWithShelf);
}

- (void)testEqualToItem
{
    Item *item = [[Item new] autorelease];
    Item *item2 = [[Item new] autorelease];
    
    // no ASIN/idString
    AssertFalse([item isEqualToItem:item2]);
    
    // has ASIN
    item2.asin = @"xxx";

    item.asin = @"xxx";
    Assert([item isEqualToItem:item2]);
    
    item.asin = @"yyy";
    AssertFalse([item isEqualToItem:item2]);
    
    // has idString
    item2.idString = @"xxx";
    item.asin = nil;
    
    item.idString = @"xxx";
    Assert([item isEqualToItem:item2]);
    
    item.idString = @"yyy";
    AssertFalse([item isEqualToItem:item2]);
}

#pragma mark - Database tests

// initial db test
- (void)testInitialTestDatabase
{
    [TestUtility initializeTestDatabase];

    for (int i = 1; i <= NUM_TEST_ITEM; i++) {
        Item *item = [Item find:i];
        AssertNotNil(item);

        Assert(item.registeredWithShelf);
        AssertNil(item.imageCache);
        
        // 比較対象データ
        Item *testItem = [TestUtility getTestItem:i];
        [self assertItemEquals:item with:testItem];
    }
}

// insert テスト
- (void)testInsert
{
    Item *item;

    [TestUtility clearDatabase];

    // 逆順で挿入
    for (int i = NUM_TEST_ITEM; i >= 1; i--) {
        item = [TestUtility getTestItem:i];

        // primary key と sorder をつぶしておく
        item.pid = -1; 
        item.sorder = -1;

        [item save];
    }

    // 読み込みテスト
    for (int i = 1; i <= NUM_TEST_ITEM; i++) {
        int pkey = NUM_TEST_ITEM - i + 1;
	
        item = [Item find:pkey];
        AssertNotNil(item);

        // 比較対象データ
        Item *testItem = [TestUtility getTestItem:i];
        testItem.pid = pkey;
        testItem.sorder = pkey;

        // チェック
        [self assertItemEquals:item with:testItem];
    }
}

// delete テスト
- (void)testDelete
{
    [TestUtility initializeTestDatabase];

    [db beginTransaction];
    for (int i = 1; i <= NUM_TEST_ITEM; i++) {
        Item *item = [Item find:i];
        AssertNotNil(item);

        // 削除する
        [item delete];

        // データが消えていることを確認する。
        item = [Item find:i];
        AssertNil(item);

        // イメージファイルも消去されていることを確認する
        // TBD
    }
    [db commitTransaction];
}	

// changeShelf テスト
- (void)testChangeShelf
{
    [TestUtility initializeTestDatabase];

    [db beginTransaction];
    for (int i = 1; i <= NUM_TEST_ITEM; i++) {
        // item 読み込み
        Item *item = [Item find:i];
        AssertNotNil(item);

        // shelf 変更しない場合でも大丈夫なことを確認する
        int origShelfId = item.shelfId;
        [item changeShelf:origShelfId];
        AssertEquals(origShelfId, item.shelfId);

        // shelf 変更
        int newShelfId = (origShelfId + 1) % 3;
        [item changeShelf:newShelfId];
        AssertEquals(newShelfId, item.shelfId);
		
        // データベースが書き変わっていることを確認する
        item = [Item find:i];
        AssertNotNil(item);

        AssertEqualInt(newShelfId, item.shelfId);
    }
}

// updateSorder のテスト
- (void)testUpdateSorder
{
    [TestUtility initializeTestDatabase];

    [db beginTransaction];
    for (int i = 1; i <= NUM_TEST_ITEM; i++) {
        // item 読み込み
        Item *item = [Item find:i];
        AssertNotNil(item);

        // 逆順に並び替える
        int newSorder = NUM_TEST_ITEM - i + 1;
        item.sorder = newSorder;
        [item save];
		
        // データベースが書き変わっていることを確認する
        item = [Item find:i];
        AssertNotNil(item);

        AssertEqualInt(newSorder, item.sorder);
    }
    [db commitTransaction];
}

//////////////////////////////////////////////////////////////////
// イメージ取得テスト

#pragma mark - Image tests

// getImage : imageURL が空のときに NoImage が返ること
- (void)testGetImageNoImage
{
    Item *item = [TestUtility getTestItem:1];

    // nil でテスト
    item.imageURL = nil;
    UIImage *noImage = [item getImage:nil]; // 本当にこれが noImage かどうかわからんけど
    STAssertNotNil(noImage, nil);
    STAssertNil(item.imageCache, nil); // キャッシュされていないことを確認

    // 再び nil でテスト
    STAssertTrue(noImage == [item getImage:nil], nil);
    STAssertNil(item.imageCache, nil);
	
    // 空文字列でテスト
    item.imageURL = @"";
    AssertEquals(noImage, [item getImage:nil]);
    AssertNil(item.imageCache);
}

// getImage : メモリ上にキャッシュされている場合はこれを返すこと
// また、イメージキャッシュをクリアすると消えること
- (void)testGetImageOnCache
{
    Item *item = [TestUtility getTestItem:1];
	
    item.imageURL = @"DUMMY";
    UIImage *cached = [[UIImage alloc] init];
    item.imageCache = cached;

    // テスト
    //   image cache の refresh の確認をこめて回数回す
    for (int i = 0; i < 100; i++) {
        AssertEquals(cached, [item getImage:nil]);
    }

    [Item clearAllImageCache];
    STAssertNil([item getImage:nil], nil);

    [cached release];
}

// イメージキャッシュテスト
- (void)testImageCache
{
    int i;
    NSMutableArray *items = [[[NSMutableArray alloc] init] autorelease];
    UIImage *testImage = [[[UIImage alloc] init] autorelease];

    [Item clearAllImageCache];

    for (i = 1; i <= MAX_IMAGE_CACHE_AGE * 2; i++) {
        // item 生成
        Item *item = [TestUtility getTestItem:i];
        [items addObject:item];

        // キャッシュに入れる
        item.imageURL = @"DUMMY";
        item.imageCache = testImage;
        [item _putImageCache];
    }

    // testImage のリファレンスカウンタ確認
    int r = [testImage retainCount];
    STAssertEquals(MAX_IMAGE_CACHE_AGE + 1, r, nil);

    // キャッシュ状況を確認
    for (i = 1; i <= MAX_IMAGE_CACHE_AGE; i++) {
        Item *item = [items objectAtIndex:i-1];
        STAssertNil(item.imageCache, nil);
    }
    for (i = MAX_IMAGE_CACHE_AGE + 1; i <= MAX_IMAGE_CACHE_AGE * 2; i++) {
        Item *item = [items objectAtIndex:i-1];
        AssertEquals(testImage, item.imageCache);
    }

    // キャッシュ全クリア
    [Item clearAllImageCache];

    // testImage のリファレンスカウンタが 1 に戻っていることを確認
    r = [testImage retainCount];
    AssertEqualInt(1, r);
}

// getImage: ファイルキャッシュからイメージがロードされることを確認する
//  このさい、キャッシュに登録されることも確認する
- (void)testGetImageFromFileCache
{
    // TBD
}

// fetchImage : imageCache が有る場合は YES が返ること

// fetchImage : imageURL が空のときは YES が返ること

// fetchImage : ダウンロード中の場合は NO が返ること　（テスト不能？？？）

// fetchImage : キャッシュファイルがある場合は YES が返ること

// fetchImage : キャッシュがない場合は、ネットワークからダウンロードすること (テスト不能？）

// cancelDownload

#pragma mark - Additional Info tests

- (void)testNumberOfAdditionalInfo
{
    Item *item = [[Item new] autorelease];
    AssertEqualInt(7, [item numberOfAdditionalInfo]);
}

- (void)testAdditionalInfoKeyAtIndex
{
    Item *item = [[Item new] autorelease];
    AssertEqualString(@"Title", [item additionalInfoKeyAtIndex:0]);
    AssertEqualString(@"Author", [item additionalInfoKeyAtIndex:1]);
    AssertEqualString(@"Manufacturer", [item additionalInfoKeyAtIndex:2]);
    AssertEqualString(@"Category", [item additionalInfoKeyAtIndex:3]);
    AssertEqualString(@"Price", [item additionalInfoKeyAtIndex:4]);
    AssertEqualString(@"Code", [item additionalInfoKeyAtIndex:5]);
    AssertEqualString(@"ASIN", [item additionalInfoKeyAtIndex:6]);
    AssertNil([item additionalInfoKeyAtIndex:7]);
    
}

- (void)testAdditionalInfoValueAtIndex
{
    Item *item = [[Item new] autorelease];
    
    item.name = @"A";
    item.author = @"B";
    item.manufacturer = @"C";
    item.category = @"D";
    item.price = @"E";
    item.idString = @"F";
    item.asin = @"G";
    
    AssertEqualString(@"A", [item additionalInfoValueAtIndex:0]);
    AssertEqualString(@"B", [item additionalInfoValueAtIndex:1]);
    AssertEqualString(@"C", [item additionalInfoValueAtIndex:2]);
    AssertEqualString(@"D", [item additionalInfoValueAtIndex:3]);
    AssertEqualString(@"E", [item additionalInfoValueAtIndex:4]);
    AssertEqualString(@"F", [item additionalInfoValueAtIndex:5]);
    AssertEqualString(@"G", [item additionalInfoValueAtIndex:6]);
    AssertNil([item additionalInfoKeyAtIndex:7]);
}

- (void)testSetAdditionalInfoValueAtIndex
{
    Item *item = [[Item new] autorelease];
    
    [item setAdditionalInfoValueAtIndex:0 withValue:@"A"];
    [item setAdditionalInfoValueAtIndex:1 withValue:@"B"];
    [item setAdditionalInfoValueAtIndex:2 withValue:@"C"];
    [item setAdditionalInfoValueAtIndex:3 withValue:@"D"];
    [item setAdditionalInfoValueAtIndex:4 withValue:@"E"];
    [item setAdditionalInfoValueAtIndex:5 withValue:@"F"];
    [item setAdditionalInfoValueAtIndex:6 withValue:@"G"];
    [item setAdditionalInfoValueAtIndex:7 withValue:@"H"]; // dummy
    
    AssertEqualString(@"A", item.name);
    AssertEqualString(@"B", item.author);
    AssertEqualString(@"C", item.manufacturer);
    AssertEqualString(@"D", item.category);
    AssertEqualString(@"E", item.price);
    AssertEqualString(@"F", item.idString);
    AssertEqualString(@"G", item.asin);
}

@end


