// Generated by O/R mapper generator ver 1.0

#import "Database.h"
#import "ItemBase.h"

@implementation ItemBase

@synthesize date = mDate;
@synthesize shelfId = mShelfId;
@synthesize serviceId = mServiceId;
@synthesize idString = mIdString;
@synthesize asin = mAsin;
@synthesize name = mName;
@synthesize author = mAuthor;
@synthesize manufacturer = mManufacturer;
@synthesize category = mCategory;
@synthesize detailURL = mDetailURL;
@synthesize price = mPrice;
@synthesize tags = mTags;
@synthesize memo = mMemo;
@synthesize imageURL = mImageURL;
@synthesize sorder = mSorder;
@synthesize star = mStar;

- (id)init
{
    self = [super init];
    return self;
}

- (void)dealloc
{
    [mDate release];
    [mIdString release];
    [mAsin release];
    [mName release];
    [mAuthor release];
    [mManufacturer release];
    [mCategory release];
    [mDetailURL release];
    [mPrice release];
    [mTags release];
    [mMemo release];
    [mImageURL release];
    [super dealloc];
}

/**
  @brief Migrate database table

  @return YES - table was newly created, NO - table already exists
*/

+ (BOOL)migrate
{
    NSArray *columnTypes = [NSArray arrayWithObjects:
        @"date", @"DATE",
        @"itemState", @"INTEGER",
        @"idType", @"INTEGER",
        @"idString", @"TEXT",
        @"asin", @"TEXT",
        @"name", @"TEXT",
        @"author", @"TEXT",
        @"manufacturer", @"TEXT",
        @"productGroup", @"TEXT",
        @"detailURL", @"TEXT",
        @"price", @"TEXT",
        @"tags", @"TEXT",
        @"memo", @"TEXT",
        @"imageURL", @"TEXT",
        @"sorder", @"INTEGER",
        @"star", @"INTEGER",
        nil];

    return [super migrate:columnTypes primaryKey:@"pkey"];
}

#pragma mark Read operations

/**
  @brief get the record matchs the id

  @param pid Primary key of the record
  @return record
*/
+ (ItemBase *)find:(int)pid
{
    Database *db = [Database instance];

    dbstmt *stmt = [db prepare:@"SELECT * FROM Item WHERE pkey = ?;"];
    [stmt bindInt:0 val:pid];

    return [self find_first_stmt:stmt];
}


/**
  finder with date

  @param key Key value
  @param cond Conditions (ORDER BY etc)
  @note If you specify WHERE conditions, you must start cond with "AND" keyword.
*/
+ (ItemBase*)find_by_date:(NSDate*)key cond:(NSString *)cond
{
    if (cond == nil) {
        cond = @"WHERE date = ? LIMIT 1";
    } else {
        cond = [NSString stringWithFormat:@"WHERE date = ? %@ LIMIT 1", cond];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    [stmt bindDate:0 val:key];
    return [self find_first_stmt:stmt];
}

+ (ItemBase*)find_by_date:(NSDate*)key
{
    return [self find_by_date:key cond:nil];
}

/**
  finder with itemState

  @param key Key value
  @param cond Conditions (ORDER BY etc)
  @note If you specify WHERE conditions, you must start cond with "AND" keyword.
*/
+ (ItemBase*)find_by_itemState:(int)key cond:(NSString *)cond
{
    if (cond == nil) {
        cond = @"WHERE itemState = ? LIMIT 1";
    } else {
        cond = [NSString stringWithFormat:@"WHERE itemState = ? %@ LIMIT 1", cond];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    [stmt bindInt:0 val:key];
    return [self find_first_stmt:stmt];
}

+ (ItemBase*)find_by_itemState:(int)key
{
    return [self find_by_itemState:key cond:nil];
}

/**
  finder with idType

  @param key Key value
  @param cond Conditions (ORDER BY etc)
  @note If you specify WHERE conditions, you must start cond with "AND" keyword.
*/
+ (ItemBase*)find_by_idType:(int)key cond:(NSString *)cond
{
    if (cond == nil) {
        cond = @"WHERE idType = ? LIMIT 1";
    } else {
        cond = [NSString stringWithFormat:@"WHERE idType = ? %@ LIMIT 1", cond];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    [stmt bindInt:0 val:key];
    return [self find_first_stmt:stmt];
}

+ (ItemBase*)find_by_idType:(int)key
{
    return [self find_by_idType:key cond:nil];
}

/**
  finder with idString

  @param key Key value
  @param cond Conditions (ORDER BY etc)
  @note If you specify WHERE conditions, you must start cond with "AND" keyword.
*/
+ (ItemBase*)find_by_idString:(NSString*)key cond:(NSString *)cond
{
    if (cond == nil) {
        cond = @"WHERE idString = ? LIMIT 1";
    } else {
        cond = [NSString stringWithFormat:@"WHERE idString = ? %@ LIMIT 1", cond];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    [stmt bindString:0 val:key];
    return [self find_first_stmt:stmt];
}

+ (ItemBase*)find_by_idString:(NSString*)key
{
    return [self find_by_idString:key cond:nil];
}

/**
  finder with asin

  @param key Key value
  @param cond Conditions (ORDER BY etc)
  @note If you specify WHERE conditions, you must start cond with "AND" keyword.
*/
+ (ItemBase*)find_by_asin:(NSString*)key cond:(NSString *)cond
{
    if (cond == nil) {
        cond = @"WHERE asin = ? LIMIT 1";
    } else {
        cond = [NSString stringWithFormat:@"WHERE asin = ? %@ LIMIT 1", cond];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    [stmt bindString:0 val:key];
    return [self find_first_stmt:stmt];
}

+ (ItemBase*)find_by_asin:(NSString*)key
{
    return [self find_by_asin:key cond:nil];
}

/**
  finder with name

  @param key Key value
  @param cond Conditions (ORDER BY etc)
  @note If you specify WHERE conditions, you must start cond with "AND" keyword.
*/
+ (ItemBase*)find_by_name:(NSString*)key cond:(NSString *)cond
{
    if (cond == nil) {
        cond = @"WHERE name = ? LIMIT 1";
    } else {
        cond = [NSString stringWithFormat:@"WHERE name = ? %@ LIMIT 1", cond];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    [stmt bindString:0 val:key];
    return [self find_first_stmt:stmt];
}

+ (ItemBase*)find_by_name:(NSString*)key
{
    return [self find_by_name:key cond:nil];
}

/**
  finder with author

  @param key Key value
  @param cond Conditions (ORDER BY etc)
  @note If you specify WHERE conditions, you must start cond with "AND" keyword.
*/
+ (ItemBase*)find_by_author:(NSString*)key cond:(NSString *)cond
{
    if (cond == nil) {
        cond = @"WHERE author = ? LIMIT 1";
    } else {
        cond = [NSString stringWithFormat:@"WHERE author = ? %@ LIMIT 1", cond];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    [stmt bindString:0 val:key];
    return [self find_first_stmt:stmt];
}

+ (ItemBase*)find_by_author:(NSString*)key
{
    return [self find_by_author:key cond:nil];
}

/**
  finder with manufacturer

  @param key Key value
  @param cond Conditions (ORDER BY etc)
  @note If you specify WHERE conditions, you must start cond with "AND" keyword.
*/
+ (ItemBase*)find_by_manufacturer:(NSString*)key cond:(NSString *)cond
{
    if (cond == nil) {
        cond = @"WHERE manufacturer = ? LIMIT 1";
    } else {
        cond = [NSString stringWithFormat:@"WHERE manufacturer = ? %@ LIMIT 1", cond];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    [stmt bindString:0 val:key];
    return [self find_first_stmt:stmt];
}

+ (ItemBase*)find_by_manufacturer:(NSString*)key
{
    return [self find_by_manufacturer:key cond:nil];
}

/**
  finder with productGroup

  @param key Key value
  @param cond Conditions (ORDER BY etc)
  @note If you specify WHERE conditions, you must start cond with "AND" keyword.
*/
+ (ItemBase*)find_by_productGroup:(NSString*)key cond:(NSString *)cond
{
    if (cond == nil) {
        cond = @"WHERE productGroup = ? LIMIT 1";
    } else {
        cond = [NSString stringWithFormat:@"WHERE productGroup = ? %@ LIMIT 1", cond];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    [stmt bindString:0 val:key];
    return [self find_first_stmt:stmt];
}

+ (ItemBase*)find_by_productGroup:(NSString*)key
{
    return [self find_by_productGroup:key cond:nil];
}

/**
  finder with detailURL

  @param key Key value
  @param cond Conditions (ORDER BY etc)
  @note If you specify WHERE conditions, you must start cond with "AND" keyword.
*/
+ (ItemBase*)find_by_detailURL:(NSString*)key cond:(NSString *)cond
{
    if (cond == nil) {
        cond = @"WHERE detailURL = ? LIMIT 1";
    } else {
        cond = [NSString stringWithFormat:@"WHERE detailURL = ? %@ LIMIT 1", cond];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    [stmt bindString:0 val:key];
    return [self find_first_stmt:stmt];
}

+ (ItemBase*)find_by_detailURL:(NSString*)key
{
    return [self find_by_detailURL:key cond:nil];
}

/**
  finder with price

  @param key Key value
  @param cond Conditions (ORDER BY etc)
  @note If you specify WHERE conditions, you must start cond with "AND" keyword.
*/
+ (ItemBase*)find_by_price:(NSString*)key cond:(NSString *)cond
{
    if (cond == nil) {
        cond = @"WHERE price = ? LIMIT 1";
    } else {
        cond = [NSString stringWithFormat:@"WHERE price = ? %@ LIMIT 1", cond];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    [stmt bindString:0 val:key];
    return [self find_first_stmt:stmt];
}

+ (ItemBase*)find_by_price:(NSString*)key
{
    return [self find_by_price:key cond:nil];
}

/**
  finder with tags

  @param key Key value
  @param cond Conditions (ORDER BY etc)
  @note If you specify WHERE conditions, you must start cond with "AND" keyword.
*/
+ (ItemBase*)find_by_tags:(NSString*)key cond:(NSString *)cond
{
    if (cond == nil) {
        cond = @"WHERE tags = ? LIMIT 1";
    } else {
        cond = [NSString stringWithFormat:@"WHERE tags = ? %@ LIMIT 1", cond];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    [stmt bindString:0 val:key];
    return [self find_first_stmt:stmt];
}

+ (ItemBase*)find_by_tags:(NSString*)key
{
    return [self find_by_tags:key cond:nil];
}

/**
  finder with memo

  @param key Key value
  @param cond Conditions (ORDER BY etc)
  @note If you specify WHERE conditions, you must start cond with "AND" keyword.
*/
+ (ItemBase*)find_by_memo:(NSString*)key cond:(NSString *)cond
{
    if (cond == nil) {
        cond = @"WHERE memo = ? LIMIT 1";
    } else {
        cond = [NSString stringWithFormat:@"WHERE memo = ? %@ LIMIT 1", cond];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    [stmt bindString:0 val:key];
    return [self find_first_stmt:stmt];
}

+ (ItemBase*)find_by_memo:(NSString*)key
{
    return [self find_by_memo:key cond:nil];
}

/**
  finder with imageURL

  @param key Key value
  @param cond Conditions (ORDER BY etc)
  @note If you specify WHERE conditions, you must start cond with "AND" keyword.
*/
+ (ItemBase*)find_by_imageURL:(NSString*)key cond:(NSString *)cond
{
    if (cond == nil) {
        cond = @"WHERE imageURL = ? LIMIT 1";
    } else {
        cond = [NSString stringWithFormat:@"WHERE imageURL = ? %@ LIMIT 1", cond];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    [stmt bindString:0 val:key];
    return [self find_first_stmt:stmt];
}

+ (ItemBase*)find_by_imageURL:(NSString*)key
{
    return [self find_by_imageURL:key cond:nil];
}

/**
  finder with sorder

  @param key Key value
  @param cond Conditions (ORDER BY etc)
  @note If you specify WHERE conditions, you must start cond with "AND" keyword.
*/
+ (ItemBase*)find_by_sorder:(int)key cond:(NSString *)cond
{
    if (cond == nil) {
        cond = @"WHERE sorder = ? LIMIT 1";
    } else {
        cond = [NSString stringWithFormat:@"WHERE sorder = ? %@ LIMIT 1", cond];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    [stmt bindInt:0 val:key];
    return [self find_first_stmt:stmt];
}

+ (ItemBase*)find_by_sorder:(int)key
{
    return [self find_by_sorder:key cond:nil];
}

/**
  finder with star

  @param key Key value
  @param cond Conditions (ORDER BY etc)
  @note If you specify WHERE conditions, you must start cond with "AND" keyword.
*/
+ (ItemBase*)find_by_star:(int)key cond:(NSString *)cond
{
    if (cond == nil) {
        cond = @"WHERE star = ? LIMIT 1";
    } else {
        cond = [NSString stringWithFormat:@"WHERE star = ? %@ LIMIT 1", cond];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    [stmt bindInt:0 val:key];
    return [self find_first_stmt:stmt];
}

+ (ItemBase*)find_by_star:(int)key
{
    return [self find_by_star:key cond:nil];
}
/**
  Get first record matches the conditions

  @param cond Conditions (WHERE phrase and so on)
  @return array of records
*/
+ (ItemBase *)find_first:(NSString *)cond
{
    if (cond == nil) {
        cond = @"LIMIT 1";
    } else {
        cond = [cond stringByAppendingString:@" LIMIT 1"];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    return  [self find_first_stmt:stmt];
}

/**
  Get all records match the conditions

  @param cond Conditions (WHERE phrase and so on)
  @return array of records
*/
+ (NSMutableArray *)find_all:(NSString *)cond
{
    dbstmt *stmt = [self gen_stmt:cond];
    return  [self find_all_stmt:stmt];
}

/**
  @brief create dbstmt

  @param s condition
  @return dbstmt
*/
+ (dbstmt *)gen_stmt:(NSString *)cond
{
    NSString *sql;
    if (cond == nil) {
        sql = @"SELECT * FROM Item;";
    } else {
        sql = [NSString stringWithFormat:@"SELECT * FROM Item %@;", cond];
    }  
    dbstmt *stmt = [[Database instance] prepare:sql];
    return stmt;
}

/**
  Get first record matches the conditions

  @param stmt Statement
  @return array of records
*/
+ (ItemBase *)find_first_stmt:(dbstmt *)stmt
{
    if ([stmt step] == SQLITE_ROW) {
        ItemBase *e = [[[[self class] alloc] init] autorelease];
        [e _loadRow:stmt];
        return (ItemBase *)e;
    }
    return nil;
}

/**
  Get all records match the conditions

  @param stmt Statement
  @return array of records
*/
+ (NSMutableArray *)find_all_stmt:(dbstmt *)stmt
{
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];

    while ([stmt step] == SQLITE_ROW) {
        ItemBase *e = [[[self class] alloc] init];
        [e _loadRow:stmt];
        [array addObject:e];
        [e release];
    }
    return array;
}

- (void)_loadRow:(dbstmt *)stmt
{
    self.pid = [stmt colInt:0];
    self.date = [stmt colDate:1];
    self.shelfId = [stmt colInt:2];
    self.serviceId = [stmt colInt:3];
    self.idString = [stmt colString:4];
    self.asin = [stmt colString:5];
    self.name = [stmt colString:6];
    self.author = [stmt colString:7];
    self.manufacturer = [stmt colString:8];
    self.category = [stmt colString:9];
    self.detailURL = [stmt colString:10];
    self.price = [stmt colString:11];
    self.tags = [stmt colString:12];
    self.memo = [stmt colString:13];
    self.imageURL = [stmt colString:14];
    self.sorder = [stmt colInt:15];
    self.star = [stmt colInt:16];
}

#pragma mark Create operations

- (void)_insert
{
    [super _insert];

    Database *db = [Database instance];
    dbstmt *stmt;
    
    //[db beginTransaction];
    stmt = [db prepare:@"INSERT INTO Item VALUES(NULL,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"];

    [stmt bindDate:0 val:mDate];
    [stmt bindInt:1 val:mShelfId];
    [stmt bindInt:2 val:mServiceId];
    [stmt bindString:3 val:mIdString];
    [stmt bindString:4 val:mAsin];
    [stmt bindString:5 val:mName];
    [stmt bindString:6 val:mAuthor];
    [stmt bindString:7 val:mManufacturer];
    [stmt bindString:8 val:mCategory];
    [stmt bindString:9 val:mDetailURL];
    [stmt bindString:10 val:mPrice];
    [stmt bindString:11 val:mTags];
    [stmt bindString:12 val:mMemo];
    [stmt bindString:13 val:mImageURL];
    [stmt bindInt:14 val:mSorder];
    [stmt bindInt:15 val:mStar];
    [stmt step];

    self.pid = [db lastInsertRowId];

    //[db commitTransaction];
}

#pragma mark Update operations

- (void)_update
{
    [super _update];

    Database *db = [Database instance];
    //[db beginTransaction];

    dbstmt *stmt = [db prepare:@"UPDATE Item SET "
        "date = ?"
        ",itemState = ?"
        ",idType = ?"
        ",idString = ?"
        ",asin = ?"
        ",name = ?"
        ",author = ?"
        ",manufacturer = ?"
        ",productGroup = ?"
        ",detailURL = ?"
        ",price = ?"
        ",tags = ?"
        ",memo = ?"
        ",imageURL = ?"
        ",sorder = ?"
        ",star = ?"
        " WHERE pkey = ?;"];
    [stmt bindDate:0 val:mDate];
    [stmt bindInt:1 val:mShelfId];
    [stmt bindInt:2 val:mServiceId];
    [stmt bindString:3 val:mIdString];
    [stmt bindString:4 val:mAsin];
    [stmt bindString:5 val:mName];
    [stmt bindString:6 val:mAuthor];
    [stmt bindString:7 val:mManufacturer];
    [stmt bindString:8 val:mCategory];
    [stmt bindString:9 val:mDetailURL];
    [stmt bindString:10 val:mPrice];
    [stmt bindString:11 val:mTags];
    [stmt bindString:12 val:mMemo];
    [stmt bindString:13 val:mImageURL];
    [stmt bindInt:14 val:mSorder];
    [stmt bindInt:15 val:mStar];
    [stmt bindInt:16 val:mPid];

    [stmt step];
    //[db commitTransaction];
}

#pragma mark Delete operations

/**
  @brief Delete record
*/
- (void)delete
{
    Database *db = [Database instance];

    dbstmt *stmt = [db prepare:@"DELETE FROM Item WHERE pkey = ?;"];
    [stmt bindInt:0 val:mPid];
    [stmt step];
}

/**
  @brief Delete all records
*/
+ (void)delete_cond:(NSString *)cond
{
    Database *db = [Database instance];

    if (cond == nil) {
        cond = @"";
    }
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM Item %@;", cond];
    [db exec:sql];
}

+ (void)delete_all
{
    [ItemBase delete_cond:nil];
}

#pragma mark Internal functions

+ (NSString *)tableName
{
    return @"Item";
}

@end
