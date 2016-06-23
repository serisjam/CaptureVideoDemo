//
//  JCCameraImageHelper.m
//  MYLabor
//
//  Created by 贾淼 on 15-6-23.
//  Copyright (c) 2015年 milestone. All rights reserved.
//

#import "JCCameraImageHelper.h"

//版本比较
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] !=NSOrderedAscending)

@interface JCCameraImageHelper () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoDataOutput *captureOutput;
@property (nonatomic, strong) AVCaptureMetadataOutput *captureMetadataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) cameraCallBacklBlock callBackBlock;
@property (nonatomic, strong) cameraCaptureOriginDataBlock captureOriginDataBlock;
@property (nonatomic, assign) BOOL isGetNextFilterImage;

@property (nonatomic, assign) JCCameraScanType cameraScanType;
@property (nonatomic, assign) AVCaptureDevicePosition captureDevicePosition;

@end

@implementation JCCameraImageHelper

- (void)dealloc {
    
    self.session = nil;
    self.captureOutput = nil;
    self.captureMetadataOutput = nil;
    self.callBackBlock = nil;
}

- (id)init {
    
    self = [super init];
    
    if (self) {
        [self initializeWithCameraScanType:self.cameraScanType];
    }
    
    return self;
}

- (id)initWithCameraScanType:(JCCameraScanType)cameraScanType
{
    self.cameraScanType = cameraScanType;
    
    self = [self init];
    
    if (self) {
        
    }
    
    return self;
}

- (void)initializeWithCameraScanType:(JCCameraScanType)cameraScanType {
    
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    CMTime frameDuration = CMTimeMake(1, 15);
    
    NSArray *supportedFrameRateRanges = [device.activeFormat videoSupportedFrameRateRanges];
    BOOL frameRateSupported = NO;
    for (AVFrameRateRange *range in supportedFrameRateRanges) {
        if (CMTIME_COMPARE_INLINE(frameDuration, >=, range.minFrameDuration) &&
            CMTIME_COMPARE_INLINE(frameDuration, <=, range.maxFrameDuration)) {
            frameRateSupported = YES;
        }
    }
    if (frameRateSupported && [device lockForConfiguration:&error]) {
        [device setActiveVideoMaxFrameDuration:frameDuration];
        [device setActiveVideoMinFrameDuration:frameDuration];
        [device unlockForConfiguration];
    }

    _captureDevicePosition = AVCaptureDevicePositionBack;
    
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    [self.session addInput:captureInput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("com.jam.camera", NULL);
    
    if (self.cameraScanType == JCCameraScanImageType || self.cameraScanType == JCCameraScanOriginType) {
        _captureOutput = [[AVCaptureVideoDataOutput alloc] init];
        _captureOutput.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], (id)kCVPixelBufferPixelFormatTypeKey, nil];
        _captureOutput.alwaysDiscardsLateVideoFrames = YES;
        [_captureOutput setSampleBufferDelegate:self queue:dispatchQueue];
        
        [self.session addOutput:_captureOutput];
        
        return ;
    }
    
    _captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.session addOutput:_captureMetadataOutput];
    
    [_captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    [_captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
}


#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if (_captureOriginDataBlock) {
        _captureOriginDataBlock(sampleBuffer);
        return ;
    }
    
    if (_callBackBlock && _isGetNextFilterImage) {
        CIImage *outputImage;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
            CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            outputImage = [[CIImage imageWithCVImageBuffer:imageBuffer] imageByApplyingTransform:[self getTransformWith:_captureDevicePosition]];
        } else {
            outputImage = [[self imageFromSampleBuffer:sampleBuffer] imageByApplyingTransform:[self getTransformWith:_captureDevicePosition]];
        }
        _isGetNextFilterImage = NO;
        BOOL isNext = NO;
        _callBackBlock(outputImage, nil, &isNext);
        _isGetNextFilterImage = isNext;
    }
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            
            if (_callBackBlock && _isGetNextFilterImage) {
                _isGetNextFilterImage = NO;
                BOOL isNext = NO;
                _callBackBlock(nil, [metadataObj stringValue], &isNext);
                _isGetNextFilterImage = isNext;
            }
        }
    }
}

#pragma mark private method

- (CIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CFRetain(sampleBuffer);
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    // Create an image object from the Quartz image
    //UIImage *image = [UIImage imageWithCGImage:quartzImage];
    CIImage *image = [CIImage imageWithCGImage:quartzImage];
//    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:UIImageOrientationRight];
//    image = [self fixOrientation:image];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    CFRelease(sampleBuffer);
    
    return image;
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    return img;
}

#pragma mark public method

-(void) embedPreviewInView:(UIView *)aView {
    if (!_session || _previewLayer) return;
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.frame = aView.bounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    if (self.cameraScanType == JCCameraScanQRType) {
        _captureMetadataOutput.rectOfInterest = CGRectMake(0, 0, 1, 1);
    }
    
    [aView.layer insertSublayer:_previewLayer atIndex:0];
}

- (void) startRunning {
    [[self session] startRunning];
    
    _isGetNextFilterImage = YES;
}

- (void) stopRunning {
    [[self session] stopRunning];
    
    _isGetNextFilterImage = NO;
}

- (void)carmeraScanBlock:(cameraCallBacklBlock)cameraCallBacklBlock {
    _callBackBlock = cameraCallBacklBlock;
}

- (void)carmeraScanOriginBlock:(cameraCaptureOriginDataBlock)cameraCaptureOriginBlock {
    _captureOriginDataBlock = cameraCaptureOriginBlock;
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}

- (void)swapFrontAndBackCameras {
    NSArray *inputs = self.session.inputs;
    for ( AVCaptureDeviceInput *input in inputs ) {
        AVCaptureDevice *device = input.device;
        if ( [device hasMediaType:AVMediaTypeVideo] ) {
            _captureDevicePosition = device.position;
            AVCaptureDevice *newCamera = nil;
            AVCaptureDeviceInput *newInput = nil;
            
            if (_captureDevicePosition == AVCaptureDevicePositionFront)
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            else
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            
            [self.session beginConfiguration];
            
            [self.session removeInput:input];
            [self.session addInput:newInput];
            
            [self.session commitConfiguration];
            break;
        }
    } 
}

- (CGAffineTransform)getTransformWith:(AVCaptureDevicePosition)captureDevicePosition {
    if (captureDevicePosition == AVCaptureDevicePositionBack) {
        return CGAffineTransformMakeRotation(-M_PI_2);
    } else {
        return CGAffineTransformScale(CGAffineTransformMakeRotation(-M_PI_2), 1, -1);
    }
}

@end
