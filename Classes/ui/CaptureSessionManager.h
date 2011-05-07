// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// reference : http://www.musicalgeometry.com/?p=1273

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@interface CaptureSessionManager : NSObject {
    AVCaptureVideoPreviewLayer *mPreviewLayer;
    AVCaptureSession *mCaptureSession;
}

@property(nonatomic,retain) AVCaptureVideoPreviewLayer *previewLayer;
@property(nonatomic,retain) AVCaptureSession *captureSession;

- (void)addVideoPreviewLayer;
- (BOOL)addVideoInput;
- (void)addVideoOutput:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)delegate;

@end
