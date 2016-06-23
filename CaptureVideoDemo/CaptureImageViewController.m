//
//  CaptureImageViewController.m
//  CaptureVideoDemo
//
//  Created by Jam on 16/5/26.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "CaptureImageViewController.h"
#import "JCH264Encoder.h"
#import "JCCameraImageHelper.h"

#import <libkern/OSAtomic.h>

/**  时间戳 */
#define NOW (CACurrentMediaTime()*1000)

@interface CaptureImageViewController ()

@property (nonatomic, strong) JCCameraImageHelper *cameraHelper;
@property (nonatomic, strong) JCH264Encoder *jcH264encoder;

@property (nonatomic, assign) uint64_t timestamp;

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
    
    //实时取景
    [_cameraHelper startRunning];
    
    _jcH264encoder = [[JCH264Encoder alloc] initEncodeWidth:480 withHeight:640];
    
    __weak typeof(self) weakSelf = self;
    [_cameraHelper carmeraScanOriginBlock:^(CMSampleBufferRef sampleBufferRef) {
        [weakSelf.jcH264encoder encodeVideoData:sampleBufferRef timeStamp:[weakSelf getCurrentTimestamp]];
        
    }];
//    [_cameraHelper carmeraScanBlock:^(CIImage *image, NSString *qrContent, BOOL *isNextFilterImage){
//        *isNextFilterImage = YES;
//    }];
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
    [_cameraHelper swapFrontAndBackCameras];
}

- (u_int64_t)getCurrentTimestamp {
    static OSSpinLock ossLock;
    static dispatch_once_t onceToken;
    static uint64_t currentts;
    
    dispatch_once(&onceToken, ^{
        ossLock = OS_SPINLOCK_INIT;
        currentts = 0;
        _timestamp = NOW;
    });
    
    OSSpinLockLock(&ossLock);
    currentts = NOW - _timestamp;
    OSSpinLockUnlock(&ossLock);
    
    return currentts;
}


@end
