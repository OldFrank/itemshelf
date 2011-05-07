// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */
// simple / adhoc DOM

#import <UIKit/UIKit.h>

@interface XmlNode : NSObject {
    NSString *name;
    XmlNode *parent;
    NSString *text;
    NSMutableDictionary *attributes;
    NSMutableArray *children;
}

@property(nonatomic, retain) NSString *name;
@property(nonatomic, assign) XmlNode *parent;
@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) NSDictionary *attributes;
@property(nonatomic, retain) NSMutableArray *children;

- (XmlNode *)findNode:(NSString *)name;
- (XmlNode *)findSibling;

- (void)dump;
- (void)dumpsub:(int)depth;

@end

@interface DomParser : NSObject {
    NSMutableString *curString;
    XmlNode *curNode;
}

- (XmlNode*)parse:(NSData *)data;

@end
