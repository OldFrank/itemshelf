// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
  ItemShelf for iPhone/iPod touch

  Copyright (c) 2008-2011, ItemShelf Development Team. All rights reserved.

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

#import "BarcodeScannerController2.h"
#import "BarcodeReader.h"

@implementation BarcodeScannerController

@synthesize delegate;

+ (BarcodeScannerController *)barcodeScannerController:(id<BarcodeScannerControllerDelegate>)delegate
{
    BarcodeScannerController *vc;
    
    vc = [[[BarcodeScannerController alloc] init] autorelease];
    vc.delegate = delegate;
    return vc;
}

- (id)init
{
    self = [super initWithNibName:@"BarcodeScannerView" bundle:nil];
    if (self) {
        mBarcodeReader = [[BarcodeReader alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [mCaptureManager release];
    [mBarcodeReader release];

    [super dealloc];
}

- (void)viewDidLoad
{
    NSLog(@"BarcodeScannerController: viewDidLoad");

    // capture manager を作る
    mCaptureManager = [[CaptureSessionManager alloc] init];

    if (![mCaptureManager addVideoInput]) {
        // TBD
    }

    // Preview capture preview を作成
    // Note: iOS 4.1 では、Output よりさきに Preview を作らないとフリーズするらしい
    [mCaptureManager addVideoPreviewLayer];
    AVCaptureVideoPreviewLayer *preview = mCaptureManager.previewLayer;
    preview.frame = mReaderArea.layer.bounds;
    [mReaderArea.layer addSublayer:preview];

    // video output を作成
    [mCaptureManager addVideoOutput:self];
    
    // バーコード用ビューをオーバーレイする
    UIImage *overlayImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BarcodeReader" ofType:@"png"]];
    overlayImage.frame = mReaderArea.bounds;
    [mReaderArea addSubview:overlayImage];

    // キャプチャ開始
    [mCaptureManager.captureSession startRunning];
}

#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)capOut didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection*)connection
{
    UIImage *image = [self _UIImageFromSampleBuffer:sampleBuffer];
    
    if ([mBarcodeReader recognize:image]) {
        NSString *code = mBarcodeReader.data;
        NSLog(@"Code = %@", code);

        if ([self isValidBarcode:code]) {
            [mCaptureManager.captureSession stopRunning];
            [self.delegate barcodeScannerController:(BarcodeScannerController*)self didRecognizeBarcode:(NSString*)code];
        } else {
            NSLog(@"Invalid code");
        }
    } else {
        NSLog(@"No code");
    }
    [image release];
}

- (UIImage *)_UIImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);

    UIImage *image = [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationRight];
    [image retain];
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(newImage);
    [pool drain];

    return image;
}

- (BOOL)isValidBarcode:(NSString *)code
{
    int n[13];
    
    if ([code length] == 13) {
        // EAN, JAN
        @try {
            for (int i = 0; i < 13; i++) {
                NSString *c = [code substringWithRange:NSMakeRange(i, 1)];
                if ([c isEqualToString:@"X"]) {
                    n[i] = 10;
                } else {
                    n[i] = [c intValue];
                }
            }
        }
        @catch (NSException *exception) {
            return NO;
        }

        int x1 = n[1] + n[3] + n[5] + n[7] + n[9] + n[11];
        x1 *= 3;

        int x2 = n[0] + n[2] + n[4] + n[6] + n[8] + n[10];
        int x = x1 + x2;

        int cd = 10 - (x % 10);
        cd = cd % 10;

        if (n[12] == cd) {
            return YES;
        }
        return NO;
    }

    // UPC or other code...
    return YES;
}

- (IBAction)onCancel:(id)sender
{
    [mCaptureSession stopRunning];
    [[self parentViewController] dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [Common isSupportedOrientation:interfaceOrientation];
}

@end
