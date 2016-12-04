//
//  JCCameraImageHelper.m
//  MYLabor
//
//  Created by 贾淼 on 15-6-23.
//  Copyright (c) 2015年 milestone. All rights reserved.
//

#import "JCCameraImageHelper.h"

@interface JCCameraImageHelper () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoDataOutput *captureOutput;
@property (nonatomic, strong) AVCaptureMetadataOutput *captureMetadataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) UIView *focusView;

@property (nonatomic, strong) JCCameraCallBacklBlock callBackBlock;
@property (nonatomic, assign) BOOL isGetNextFilterImage;
@property (nonatomic, assign) JCCameraScanType cameraScanType;

@end

@implementation JCCameraImageHelper

- (void)dealloc {
    
    self.session = nil;
    self.captureOutput = nil;
    self.captureMetadataOutput = nil;
    self.callBackBlock = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init {
    self = [super init];
    
    if (self) {
        [self initializeWithCameraScanType:self.cameraScanType];
    }
    
    return self;
}

- (id)initWithCameraScanType:(JCCameraScanType)cameraScanType {
    self.cameraScanType = cameraScanType;
    
    self = [self init];
    
    if (self) {
    }
    
    return self;
}

- (void)initializeWithCameraScanType:(JCCameraScanType)cameraScanType {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [self setCaptureTorchMode:AVCaptureTorchModeAuto];
    NSError *error;
    
    self.session = [[AVCaptureSession alloc] init];
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    [self.session addInput:captureInput];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("com.jam.camera", NULL);
    
    if (self.cameraScanType == JCCameraScanImageType) {
        _captureOutput = [[AVCaptureVideoDataOutput alloc] init];
        _captureOutput.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], (id)kCVPixelBufferPixelFormatTypeKey, nil];
        _captureOutput.alwaysDiscardsLateVideoFrames = YES;
        [_captureOutput setSampleBufferDelegate:self queue:dispatchQueue];
        [self.session addOutput:_captureOutput];
        [self setRelativeVideoOrientation];
        return ;
    }
    
    _captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [self.session addOutput:_captureMetadataOutput];
    
    _captureMetadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,
                                                   AVMetadataObjectTypeUPCECode,
                                                   AVMetadataObjectTypeCode39Code,
                                                   AVMetadataObjectTypeCode39Mod43Code,
                                                   AVMetadataObjectTypeEAN13Code,
                                                   AVMetadataObjectTypeEAN8Code,
                                                   AVMetadataObjectTypeCode93Code,
                                                   AVMetadataObjectTypeCode128Code,
                                                   AVMetadataObjectTypePDF417Code,
                                                   AVMetadataObjectTypeAztecCode];
}


#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (_callBackBlock && _isGetNextFilterImage) {
        UIImage *outputImage = [self imageFromSampleBuffer:sampleBuffer];
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
        if (_callBackBlock && _isGetNextFilterImage) {
            _isGetNextFilterImage = NO;
            BOOL isNext = NO;
            _callBackBlock(nil, [metadataObj stringValue], &isNext);
            _isGetNextFilterImage = isNext;
        }
    }
}

#pragma mark -- NSNotification
- (void)willEnterBackground:(NSNotification*)notification {
    [self stopRunning];
}

- (void)willEnterForeground:(NSNotification*)notification {
    [self startRunning];
}

#pragma mark private method

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
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
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:UIImageOrientationRight];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    CFRelease(sampleBuffer);
    
    return image;
}

- (void)setRelativeVideoOrientation {
    AVCaptureConnection *connection = [_captureOutput connectionWithMediaType:AVMediaTypeVideo];
    
    switch ([[UIDevice currentDevice] orientation]) {
        case UIInterfaceOrientationPortrait:
#if defined(__IPHONE_8_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
        case UIInterfaceOrientationUnknown:
#endif
            connection.videoOrientation = AVCaptureVideoOrientationPortrait;
            
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            connection.videoOrientation =
            AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeRight:
            connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        default:
            break;
    }
    
}

#pragma mark private method

- (void)animateFocusView {
    [self.focusView.layer removeAllAnimations];
    
    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionBeginFromCurrentState animations:^{
        CGFloat height = _scanRect.size.width*0.35;
        self.focusView.center = CGPointMake(CGRectGetMidX(_scanRect), CGRectGetMidY(_scanRect));
        self.focusView.bounds = CGRectMake(0, 0, _scanRect.size.width, height);
    } completion:nil];
}

#pragma mark public method

-(void) embedPreviewInView:(UIView *)aView {
    if (!_session || _previewLayer) return;
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.frame = aView.bounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    if ([_previewLayer.connection isVideoOrientationSupported]) {
        _previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    
    if (self.cameraScanType == JCCameraScanCodeType) {
        _isAvailable = YES;
        if (![[aView subviews] containsObject:self.focusView]) {
            [aView addSubview:self.focusView];
        }
        [self setScanRect:CGRectMake(aView.bounds.size.width*0.2, aView.bounds.size.height*0.2, aView.bounds.size.width*0.6, aView.bounds.size.width*0.6)];
    }
    
    [aView.layer insertSublayer:_previewLayer atIndex:0];
}

- (void)setIsAvailable:(BOOL)isAvailable {
    if (isAvailable) {
        [self.focusView setHidden:NO];
        [self animateFocusView];
        return ;
    }
    [self.focusView setHidden:YES];
    [self.focusView.layer removeAllAnimations];
}

- (void)setCaptureTorchMode:(AVCaptureTorchMode)captureTorchMode {
    _captureTorchMode = captureTorchMode;
    
    AVCaptureDevice *backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([backCamera isTorchAvailable] && [backCamera isTorchModeSupported:AVCaptureTorchModeOn]) {
        BOOL success = [backCamera lockForConfiguration:nil];
        if (success) {
            [backCamera setTorchMode:_captureTorchMode];
            [backCamera unlockForConfiguration];
        }
    }
}

- (void)setScanRect:(CGRect)scanRect {
    NSAssert(!CGRectIsEmpty(scanRect), @"Unable to set an empty rectangle as the scanRect of MTBBarcodeScanner");
    if (self.cameraScanType != JCCameraScanCodeType) {
        return ;
    }
    _scanRect = scanRect;
    CGFloat width = _scanRect.size.width > _scanRect.size.height ? _scanRect.size.height : _scanRect.size.width;
    width -= width * 0.15f;
    self.focusView.center = CGPointMake(CGRectGetMidX(_scanRect), CGRectGetMidY(_scanRect));
    self.focusView.bounds = CGRectMake(0, 0, width, width);
    CGRect resultRect = [_previewLayer metadataOutputRectOfInterestForRect:_scanRect];
    _captureMetadataOutput.rectOfInterest = resultRect;
    [self animateFocusView];
}


- (void) startRunning {
    [[self session] startRunning];
    _isGetNextFilterImage = YES;
}

- (void) stopRunning {
    [[self session] stopRunning];
    _isGetNextFilterImage = NO;
}

- (void)carmeraScanBlock:(JCCameraCallBacklBlock)cameraCallBacklBlock {
    _callBackBlock = cameraCallBacklBlock;
}

#pragma mark Setter/Getter

- (UIView *)focusView {
    if (!_focusView) {
        _focusView = [[UIView alloc] init];
        _focusView.layer.borderColor = [UIColor whiteColor].CGColor;
        _focusView.layer.borderWidth = 2.0f;
        _focusView.layer.cornerRadius = 5.0f;
        _focusView.layer.shadowColor = [UIColor whiteColor].CGColor;
        _focusView.layer.shadowRadius = 10.0f;
        _focusView.layer.shadowOpacity = 0.9f;
        _focusView.layer.shadowOffset = CGSizeZero;
        _focusView.layer.masksToBounds = false;
    }
    return _focusView;
}

@end
