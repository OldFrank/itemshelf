// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * ItemShelf for iOS
 * Copyright (C) 2008-2011, ItemShelf Development Team, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// reference : http://www.musicalgeometry.com/?p=1273

#import "CaptureSessionManager.h"

@implementation CaptureSessionManager

@synthesize captureSession = mCaptureSession;
@synthesize previewLayer = mPreviewLayer;

- (id)init
{
    self = [super init];
    if (self) {
        self.captureSession = [[[AVCaptureSession alloc] init] autorelease];

        // プリセット設定
        [mCaptureSession beginConfiguration];
        mCaptureSession.sessionPreset = AVCaptureSessionPresetMedium;
        [mCaptureSession commitConfiguration];
    }
    return self;
}

- (void)dealloc
{
    [self.captureSession stopRunning];

    self.previewLayer = nil;
    self.captureSession = nil;

    [super dealloc];
}

- (BOOL)setup:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)delegate
{
    if (![self addVideoInput]) {
        return NO;
    }

    // Note: iOS 4.1 では、Output よりさきに Preview を作らないとフリーズするらしい
    [self addVideoPreviewLayer];
    [self addVideoOutput:delegate];
    return YES;
}

- (void)addVideoPreviewLayer
{
    self.previewLayer = [[[AVCaptureVideoPreviewLayer alloc]
                             initWithSession:self.captureSession] autorelease];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
}

- (BOOL)addVideoInput
{
    AVCaptureDevice *dev = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!dev) {
        NSLog(@"Couldn't add video device");
        return NO;
    }

    if ([dev isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        NSError *error;
        if ([dev lockForConfiguration:&error]) {
            dev.focusMode = AVCaptureFocusModeContinuousAutoFocus;
            [dev unlockForConfiguration];
        } else {
            NSLog(@"Couldn't set auto focus");
        }
    }

    NSError *error;
    AVCaptureDeviceInput *capIn = [AVCaptureDeviceInput deviceInputWithDevice:dev error:&error];
    if (error) {
        // TBD : error
        return NO;
    } else {
        [self.captureSession addInput:capIn];
    }
    return YES;
}

- (void)addVideoOutput:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)delegate
{
    // AVCaptureVideoDataOutput を作成
    AVCaptureVideoDataOutput *capOut = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
    [self.captureSession addOutput:capOut];

    capOut.alwaysDiscardsLateVideoFrames = YES;
    [capOut setSampleBufferDelegate:delegate queue:dispatch_get_main_queue()];

    // Output の pixel format を指定
    NSDictionary *videoSettings =
        [NSDictionary
            dictionaryWithObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]
                          forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
    [capOut setVideoSettings:videoSettings];

    //capOut.minFrameDuration = CMTimeMake(1, 8);
}

@end
