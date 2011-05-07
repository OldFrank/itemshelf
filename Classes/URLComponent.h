// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "Common.h"

/**
   URL query parameter
*/
@interface URLQuery : NSObject
{
    NSString *name;	///< parameter name
    NSString *value;	///< value of the parameter
}

@property(nonatomic,retain) NSString *name;
@property(nonatomic,retain) NSString *value;

@end

/**
   URL component class

   It likes NSURL. Main difference is that this class
   can handle "splitted" URL parameters with URLQuery class.
*/
@interface URLComponent : NSObject
{
    NSString *scheme;
    NSString *host;
    NSString *path;
    NSString *params;
    NSString *query;
    NSString *fragment;

    NSMutableArray *queries;  ///< Query parameters
}

@property(nonatomic,retain) NSString *scheme;
@property(nonatomic,retain) NSString *host;
@property(nonatomic,retain) NSString *path;
@property(nonatomic,retain) NSString *params;
@property(nonatomic,retain) NSString *query;
@property(nonatomic,retain) NSString *fragment;
@property(nonatomic,retain) NSMutableArray *queries;

- (id)initWithURL:(NSURL *)url;
- (id)initWithURLString:(NSString *)urlString;
- (void)setURL:(NSURL *)url;
- (void)setURLString:(NSString*)urlString;
- (NSString*)absoluteString;
- (NSURL*)url;

- (void)parseQuery;
- (void)composeQuery;

- (URLQuery*)URLQuery:(NSString*)name; // private
- (NSString*)query:(NSString*)name;
- (void)setQuery:(NSString*)name value:(NSString*)value;
- (void)removeQuery:(NSString*)name;

- (void)log;

@end
