//
//  CaptureImageViewController.m
//  CaptureVideoDemo
//
//  Created by Jam on 16/5/26.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import <libkern/OSAtomic.h>

#import "CaptureImageViewController.h"
#import "JCCameraImageHelper.h"
#import "JCH264Encoder.h"

/**  时间戳 */
#define NOW (CACurrentMediaTime()*1000)

@interface CaptureImageViewController () <JCH264EncoderDelegate>

@property (nonatomic, strong) JCCameraImageHelper *cameraHelper;
@property (nonatomic, strong) JCH264Encoder *jcH264Encoder;

@property (nonatomic, assign) uint64_t timestamp;

@property (nonatomic, strong) NSFileHandle *h264FileHandle;

@end

@implementation CaptureImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _cameraHelper = [[JCCameraImageHelper alloc] initWithCameraScanType:JCCameraScanOriginType];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [_cameraHelper embedPreviewInView:self.view];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //打开文件句柄, 记录h264文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *h264File = [documentsDirectory stringByAppendingPathComponent:@"test.h264"];
    [fileManager removeItemAtPath:h264File error:nil];
    [fileManager createFileAtPath:h264File contents:nil attributes:nil];
    
    self.h264FileHandle = [NSFileHandle fileHandleForWritingAtPath:h264File];
    
    //实时取景
    [_cameraHelper startRunning];
    
    self.jcH264Encoder = [[JCH264Encoder alloc] initEncodeWidth:540.0 withHeight:960.0];
    [self.jcH264Encoder setDelegate:self];
    
    __weak typeof(self) weakSelf = self;
    
    [_cameraHelper carmeraScanOriginBlock:^(CMSampleBufferRef sampleBufferRef){
        [weakSelf.jcH264Encoder encodeVideoData:sampleBufferRef timeStamp:[weakSelf currentTimestamp]];
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_cameraHelper stopRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onSwitch:(id)sender {
//    [_cameraHelper swapFrontAndBackCameras];
    
    [_cameraHelper stopRunning];
    [self.jcH264Encoder endVideoCompression];
    [self.h264FileHandle closeFile];
}

#pragma mark JCH264EncoderDelegate

- (void)getEncodedData:(NSData *)data isKeyFrame:(BOOL)isKeyFrame {
    NSLog(@"gotEncodedData %d", (int)[data length]);
    
    if (self.h264FileHandle != NULL)
    {
        const char bytes[] = "\x00\x00\x00\x01";
        size_t length = (sizeof bytes) - 1; //string literals have implicit trailing '\0'
        NSData *ByteHeader = [NSData dataWithBytes:bytes length:length];
        [self.h264FileHandle writeData:ByteHeader];
        [self.h264FileHandle writeData:data];
    }
}

- (void)getSpsData:(NSData *)spsData withPpsData:(NSData *)ppsData {
    const char bytes[] = "\x00\x00\x00\x01";
    size_t length = (sizeof bytes) - 1; //string literals have implicit trailing '\0'
    NSData *ByteHeader = [NSData dataWithBytes:bytes length:length];
    [self.h264FileHandle writeData:ByteHeader];
    [self.h264FileHandle writeData:spsData];
    [self.h264FileHandle writeData:ByteHeader];
    [self.h264FileHandle writeData:ppsData];
}

#pragma mark private

- (uint64_t)currentTimestamp{
    
    static OSSpinLock lock;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lock = OS_SPINLOCK_INIT;
        _timestamp = NOW;
    });
    
    OSSpinLockLock(&lock);
    uint64_t currentts = NOW - _timestamp;
    OSSpinLockUnlock(&lock);
    
    return currentts;
}

@end
