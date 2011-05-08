// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import <SenTestingKit/SenTestingKit.h>

#import "ItemshelfDatabase.h"
#import "DataModel.h"
#import "Shelf.h"
#import "Item.h"

#define NUM_TEST_SHELF 10
#define NUM_TEST_ITEM	100

@interface TestUtility : NSObject {
}

+ (void)clearDatabase;
+ (void)initializeTestDatabase;
+ (Shelf *)getTestShelf:(int)id;
+ (Item *)getTestItem:(int)id;

#define NOTYET STFail(@"not yet")

// Simplefied macros
#define NOTYET STFail(@"not yet")
#define Assert(x) STAssertTrue(x, @"")
#define AssertTrue(x) STAssertTrue(x, @"")
#define AssertFalse(x) STAssertFalse(x, @"")
#define AssertNil(x) STAssertNil(x, @"")
#define AssertNotNil(x) STAssertNotNil(x, @"")
#define AssertEquals(a, b) STAssertEquals(a, b, @"")
#define AssertEqualInt(a, b) STAssertEquals((int)(a), (int)(b), @"")
#define AssertEqualDouble(a, b) STAssertEquals((double)(a), (double)(b), @"")
#define AssertEqualString(a, b) STAssertEqualObjects(a, b, @"")
#define AssertEqualObjects(a, b) STAssertEqualObjects(a, b, @"")

@end
