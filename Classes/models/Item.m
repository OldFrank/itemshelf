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

#import "ItemBase.h"
#import "Item.h"
#import "AppDelegate.h"
#import "DataModel.h"

@implementation Item

@synthesize imageCache = mImageCache;
@synthesize registeredWithShelf = mRegisteredWithShelf;
//@synthesize infoStrings;

- (id)init
{
    self = [super init];
    if (self) {
        self.date = [NSDate date];  // 現在時刻で生成
        self.shelfId = 0; // unclassified shelf
        self.serviceId = -1;
        self.idString = @"";
        self.asin = @"";
        self.name = @"";
        self.author = @"";
        self.manufacturer = @"";
        self.category = @"";
        self.detailURL = @"";
        self.price = @"";
        self.tags = @"";
        self.memo = @"";
        self.imageURL = @"";
        self.sorder = -1;
        self.star = 0;
        self.registeredWithShelf = NO;
    }
    return self;
}

- (void)dealloc
{
    [mImageCache release];
    //[infoStrings release];
	
    [super dealloc];
}

#pragma mark - Utility functions

/**
   Check if the item is equal.

   asin field is used to compare items.
*/
- (BOOL)isEqualToItem:(Item*)item
{
    // ASIN で比較
    if (self.asin.length > 0 && [self.asin isEqualToString:item.asin]) {
        return YES;
    }
    // idString で比較
    if (self.idString.length > 0 && [self.idString isEqualToString:item.idString]) {
        return YES;
    }
    return NO;
}

/**
   Update item
*/
- (void)updateWithNewItem:(Item *)item
{
    // do not replace local defined variables...

    //self.pkey = item.pkey;
    self.date = item.date;
    //self.shelfId = item.shelfId;
    self.serviceId = item.serviceId;
    if (item.idString != nil) self.idString = item.idString;
    self.asin = item.asin;
    self.name = item.name;
    self.author = item.author;
    self.manufacturer = item.manufacturer;
    self.category = item.category;
    self.detailURL = item.detailURL;
    self.price = item.price;
    //self.tags = item.tags;
    //self.memo = item.memo;
    self.imageURL = item.imageURL;
    //self.sorder = item.sorder;
    self.star = item.star;

    [self save];
}

////////////////////////////////////////////////////////////////////

#pragma mark - ItemBase override

- (void)_insert
{
    [super _insert];
    
    self.sorder = self.pid;  // 初期並び順は Primary Key と同じにしておく(最大値)
    [self save];
}

- (void)_loadRow:(dbstmt *)stmt
{
    [super _loadRow:stmt];
    
    // 棚登録済み
    self.registeredWithShelf = YES;
}

/**
   @name Database operation
*/
//@{

// Override
- (void)delete
{
    [self _deleteImageFile];
    [super delete];
}

- (void)changeShelf:(int)shelf
{
    if (self.shelfId == shelf) {
        return; // do nothing
    }
    self.shelfId = shelf;

    if (self.pid < 0) {
        return;	 // fail safe
    }

    [self save];
}

//@}

////////////////////////////////////////////////////////////////////

#pragma mark - Image operations

/**
   @name Image operation
*/
//@{

/**
   Return "NoImage" image (private)
*/
- (UIImage *)_getNoImage
{
    static UIImage *noImage = nil;
	
    if (noImage == nil) {
        noImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NoImage" ofType:@"png"]];
        [noImage retain];
    }
    return noImage;	
}

/**
   Image cache array (aging array)
*/
static NSMutableArray *agingArray = nil;

/**
   Clear all image cache on memory.

   This is called when memory low state.
*/
+ (void)clearAllImageCache
{
    NSLog(@"clearAllImageCache - maybe low memory");
	
    for (Item *item in agingArray) {
        item.imageCache = nil;
    }
    [agingArray removeAllObjects];
}

/**
   Refresh age of this item in image cache (private)
*/
- (void)_refreshImageCache
{
    if (agingArray == nil) {
        agingArray = [[NSMutableArray alloc] initWithCapacity:MAX_IMAGE_CACHE_AGE];
    }
	
    [agingArray removeObject:self];
    [agingArray addObject:self];
}

/**
   Put item in image cache (private)
*/
- (void)_putImageCache
{
    if (agingArray == nil) {
        agingArray = [[NSMutableArray alloc] initWithCapacity:MAX_IMAGE_CACHE_AGE];
    }
	
    [agingArray addObject:self];

    // aging 処理
    if (agingArray.count > MAX_IMAGE_CACHE_AGE) {
        Item *expire = [agingArray objectAtIndex:0];
        expire.imageCache = nil;
        [agingArray removeObjectAtIndex:0];
        //LOG(@"image expire");
    }
}	

/**
   Get image of item

   Returns image from:

   1) Cache on memory (if it is on the cache)
   2) Saved image on the file system.
   3) Download image from the server.
*/
- (UIImage *)getImage:(id<ItemDelegate>)delegate
{
    // Returns image on memory cache
    if (mImageCache != nil) {
        [self _refreshImageCache];
        return mImageCache;
    }

    // Can't return image when downloading it.
    if (mBuffer != nil) {
        return nil;
    }

    // Check cache file on the file system.
    [self _fixImagePath];

    NSString *imagePath = [self _imagePath];
    if (imagePath != nil && [[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
#if 1
        // Cache exists.
        self.imageCache = [UIImage imageWithContentsOfFile:imagePath];
        [self _putImageCache];
        return self.imageCache;
#else
        if (delegate == nil) return nil;
        // Load cache file on back ground.
        itemDelegate = delegate;
        NSInvocationOperation *op = [[[NSInvocationOperation alloc] 
                                         initWithTarget:self
                                         selector:@selector(taskLoadImage:) 
                                         object:nil] autorelease];
        [[AppDelegate sharedOperationQueue] addOperation:op];
        return nil;
#endif
    }
    
    // Returns "NoImage" if no image URL.
    if (mImageURL == nil || mImageURL.length == 0) { // TODO
        return [self _getNoImage];
    }

    // No cache. Start download image from network.
    if (delegate == nil) return nil;
    mItemDelegate = delegate;
	
    NSURLRequest *req =
        [NSURLRequest requestWithURL:[NSURL URLWithString:self.imageURL]
                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                      timeoutInterval:30.0];

    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    if (conn) {
        mBuffer = [[NSMutableData data] retain];
        LOG(@"Loading image: %@", self.imageURL);
        [conn release];
    }
	
    return nil;
}

#if 0
- (void)taskLoadImage:(id)dummy
{
    // TBD 排他制御
    self.imageCache = [UIImage imageWithContentsOfFile:[self _imagePath]];
    [self _putImageCache];

    if (itemDelegate) {
        [NSThread performSelectorOnMainThread:@selector(itemDidFinishDownloadImage:) 
                  withObject:itemDelegate];
    }
}
#endif

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
    [mBuffer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn
{
    LOG(@"Loading image done");
	
    [self saveImageCache:nil data:mBuffer];
    [mBuffer release];
    mBuffer = nil;
	
    if (mItemDelegate) {
        [mItemDelegate itemDidFinishDownloadImage:self];
    }
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
    [mBuffer release];
    mBuffer = nil;
	
    LOG(@"Connection failed. Error - %@ %@",
        [error localizedDescription],
        [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

/**
   Save image cache file
*/
- (void)saveImageCache:(UIImage *)image data:(NSData *)data
{
    // set image cache to Item
    if (image == nil) {
        image = [UIImage imageWithData:data];
    }
    image = [Common resizeImageWithin:image width:180 height:180];
    self.imageCache = image;

    // Write cache file
    if (data == nil) {
        data = UIImageJPEGRepresentation(image, 0.8);
    }
    NSString *imagePath = [self _imagePath];
    if (imagePath) {
        [data writeToFile:imagePath atomically:NO];
    }
}

/**
   Cancel image download
*/
- (void)cancelDownload
{
    mItemDelegate = nil;
}

/**
  Get image (cache) file name (full path) (private)
*/
- (NSString *)_imagePath
{
    if (self.pid < 0) return nil;

    NSString *filename = [NSString stringWithFormat:@"img-%d.jpg", self.pid];
    return [AppDelegate pathOfDataFile:filename];
}

/**
  Fix image extension (for backward compat.)
*/
- (void)_fixImagePath
{
    if (self.pid < 0) return;

    NSFileManager *fm = [NSFileManager defaultManager];

    NSString *oldfilename = [NSString stringWithFormat:@"img-%d", self.pid];
    NSString *oldpath = [AppDelegate pathOfDataFile:oldfilename];

    if (![fm fileExistsAtPath:oldpath]) return;

    NSString *newfilename = [NSString stringWithFormat:@"img-%d.jpg", self.pid];
    NSString *newpath = [AppDelegate pathOfDataFile:newfilename];

    if ([fm fileExistsAtPath:newpath]) {
        [fm removeItemAtPath:oldpath error:NULL];
    } else {
        [fm moveItemAtPath:oldpath toPath:newpath error:NULL];
        NSLog(@"image renamed : %@ -> %@", oldpath, newpath);
    }
}

/**
   Delege image (cache) file (private)
*/
- (void)_deleteImageFile
{
    NSString *path = [self _imagePath];
    if (path == nil) return;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:NULL];
}

/**
   Delete all image cache
*/
+ (void)deleteAllImageCache
{
    NSString *dataDir = [AppDelegate pathOfDataFile:nil];

    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *de = [fm enumeratorAtPath:dataDir];

    NSString *name;
    while (name = [de nextObject]) {
        if ([[name substringToIndex:4] isEqualToString:@"img-"]) {
            NSString *path = [dataDir stringByAppendingPathComponent:name];
            [fm removeItemAtPath:path error:NULL];
        }
    }
}

//@}

// Additional info
- (int)numberOfAdditionalInfo
{
    return 7;
}

- (NSString *)additionalInfoKeyAtIndex:(int)idx
{
    switch (idx) {
    case 0: return @"Title";
    case 1: return @"Author";
    case 2: return @"Manufacturer";
    case 3: return @"Category";
    case 4: return @"Price";
    case 5: return @"Code";
    case 6: return @"ASIN";
    }
    return nil;
 }

- (NSString *)additionalInfoValueAtIndex:(int)idx
{
    switch (idx) {
        case 0: return mName;
        case 1: return mAuthor;
        case 2: return mManufacturer;
        case 3: return mCategory; //NSLocalizedString(category, @"");
        case 4: return mPrice;
        case 5: return mIdString;
        case 6: return mAsin;
    }
    return nil;
}

- (BOOL)isAdditionalInfoEditableAtIndex:(int)idx
{
    return YES;
}    

- (void)setAdditionalInfoValueAtIndex:(int)idx withValue:(NSString *)value
{
    switch (idx) {
        case 0: self.name = value; break;
        case 1: self.author = value; break;
        case 2: self.manufacturer = value; break;
        case 3: self.category = value; break;
        case 4: self.price = value; break;
        case 5: self.idString = value; break;
        case 6: self.asin = value; break;
    }
}

@end
