// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// URL compomnents

// Structure of URL
//
//     <scheme>://<net_loc>/<path>;<params>?<query>#<fragment>

// ASCII code:
//   0x26 : &
//   0x3D : =
//   0x3F : ?

#import "URLComponent.h"

@implementation URLQuery
@synthesize name, value;

- (void)dealloc
{
    [name release];
    [value release];
    [super dealloc];
}

@end

@implementation URLComponent

@synthesize scheme, host, path, params, query, fragment, queries;

- (void)dealloc
{
    [scheme release];
    [host release];
    [path release];
    [params release];
    [query release];
    [fragment release];
    [queries release];

    [super dealloc];
}

/**
   Initialize with NSURL
*/
- (id)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        [self setURL:url];
    }
    return self;
}

/**
   Initialize with URL String
*/
- (id)initWithURLString:(NSString *)urlString
{
    self = [super init];
    if (self) {
        [self setURLString:urlString];
    }
    return self;
}

/**
   Set URL
*/
- (void)setURL:(NSURL *)url
{
    self.scheme = url.scheme;
    self.host = [url host];
    self.path = [url path];
    self.params = [url parameterString];
    self.query = [url query];
    self.fragment = [url fragment];

    [self parseQuery];
}

/**
   Set URL string
   
   @note Some characters (?, =, ; etc.) in the URL will be decoded to analyze it.
   (Because the URL in response of Amazon API is encoded.)
*/
- (void)setURLString:(NSString *)urlString
{
    NSMutableString *ms = [[[NSMutableString alloc] init] autorelease];
    [ms setString:urlString];

#define REPLACE(x, y)                                                   \
    [ms replaceOccurrencesOfString:x withString:y options:NSLiteralSearch range:NSMakeRange(0, [ms length])]
    REPLACE(@"%23", @"#");
    REPLACE(@"%26", @"&");
    REPLACE(@"%3B", @";");
    REPLACE(@"%3D", @"=");
    REPLACE(@"%3F", @"?");
	
    NSURL *url = [NSURL URLWithString:ms];
    [self setURL:url];
}

/**
   Return absolute URL string
*/
- (NSString*)absoluteString
{
    [self composeQuery];

    NSString *s = [NSString stringWithFormat:@"%@://%@%@", scheme, host, path];
    if (params) {
        s = [s stringByAppendingFormat:@";%@", params];
    }
    if (query) {
        s = [s stringByAppendingFormat:@"?%@", query];
    }
    if (fragment) {
        s = [s stringByAppendingFormat:@"#%@", fragment];
    }
    return s;
}

/**
   Return NSURL
*/
- (NSURL*)url
{
    NSURL *url = [NSURL URLWithString:[self absoluteString]];
    return url;
}

/**
   Parse query string to 'queries' member (private)
*/
- (void)parseQuery
{
    self.queries = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];

    NSArray *qary = [self.query componentsSeparatedByString:@"&"];

    for (NSString *q in qary) {
        if ([q isEqualToString:@""]) continue;  // for safety
		
        NSArray *nv = [q componentsSeparatedByString:@"="];
        URLQuery *p = [[URLQuery alloc] init];
        p.name = [[nv objectAtIndex:0]
                     stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        p.value = [[nv objectAtIndex:1]
                      stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        [queries addObject:p];
        [p release];
    }
}

/**
   Compose query string from 'queries' member (private)
*/
- (void)composeQuery
{
    NSMutableString *q = nil;

    for (URLQuery *p in self.queries) {
        NSString *name = [p.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *value = [p.value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        if (q == nil) {
            q = [NSMutableString stringWithCapacity:64];
            [q appendFormat:@"%@=%@", name, value];
        } else {
            [q appendFormat:@"&%@=%@", name, value];
        }
    }

    self.query = q;
}

/**
   Get URLQuery of name

   @param[in] name Name of the URL query parameter.
   @return URLQuery instance if found.
*/
- (URLQuery*)URLQuery:(NSString*)name
{
    for (URLQuery *p in self.queries) {
        if ([p.name isEqualToString:name]) {
            return p;
        }
    }
    return nil;
}

/**
   Get query parameter value of name

   @param[in] name Name of the URL query parameter.
   @return value
*/
- (NSString*)query:(NSString*)name
{
    URLQuery *p = [self URLQuery:name];
    if (p) {
        return p.value;
    }
    return nil;
}

/**
   Set query parameter

   @param[in] name Name of the parameter
   @param[in] value Value of the parameter

   @note If same parameter exist, it will be overwritten.
*/
- (void)setQuery:(NSString*)name value:(NSString*)value
{
    URLQuery *p = [self URLQuery:name];
    if (p) {
        p.value = value;
        return;
    }
    
    p = [[URLQuery alloc] init];
    p.name = name;
    p.value = value;
    [self.queries addObject:p];
    [p release];
}

/**
   Remove query parameter
*/
- (void)removeQuery:(NSString*)name
{
    URLQuery *p = [self URLQuery:name];
    if (p) {
        [self.queries removeObject:p];
    }
}

/**
   Debug log
*/
- (void)log
{
#ifdef DEBUG
    NSLog(@"URL = %@", [self absoluteString]);
    NSLog(@"scheme   %@", scheme);
    NSLog(@"host     %@", host);
    NSLog(@"path     %@", path);
    NSLog(@"params   %@", params);

    for (URLQuery *p in self.queries) {
        NSLog(@"query    %@ = %@", p.name, p.value);
    }
    NSLog(@"fragment %@", fragment);
#endif
}

@end
