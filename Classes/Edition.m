// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */
#import "Edition.h"

@implementation Edition

+ (BOOL)isLiteEdition
{
#ifdef LITE_EDITION
    return YES;
#else
    return NO;
#endif
}

@end
