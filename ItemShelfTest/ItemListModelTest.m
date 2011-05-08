// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestUtility.h"
#import "ItemListModel.h"

@interface ItemListModelTest : SenTestCase {
}
@end


@implementation ItemListModelTest

- (void)setUp
{
}

- (void)tearDown
{
}

#pragma mark - Fundamental tests

// initialize test
- (void)testInitWithShelf
{
    Shelf *shelf = [Shelf find:1];
    ItemListModel *model = [[[ItemListModel alloc] initWithShelf:shelf] autorelease];

    AssertEquals(model.shelf, shelf);
    
    // フィルタは設定していないので、カウントが同じになるはず
    AssertEqualInt([shelf itemCount], [model count]);
}

#pragma mark - Filter tests

// NOT YET

#pragma mark - Sort tests

// NOT YET

@end


