//
//  ViewController.m
//  CaptureVideoDemo
//
//  Created by Jam on 16/5/26.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "ViewController.h"
#import "JCCameraImageHelper.h"

@interface ViewController ()

@property (nonatomic, strong) JCCameraImageHelper *cameraHelper;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _cameraHelper = [[JCCameraImageHelper alloc] initWithCameraScanType:JCCameraScanCodeType];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [_cameraHelper embedPreviewInView:self.view];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //实时取景
    [_cameraHelper startRunning];
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [weakSelf.cameraHelper carmeraScanBlock:^(UIImage *image, NSString *qrContent, BOOL *isNextFilterImage){
            NSLog(@"%@", qrContent);
            *isNextFilterImage = NO;
        }];
    });
}

- (IBAction)onTorch:(id)sender {
    if (_cameraHelper.captureTorchMode == AVCaptureTorchModeAuto || _cameraHelper.captureTorchMode == AVCaptureTorchModeOff) {
        [_cameraHelper setCaptureTorchMode:AVCaptureTorchModeOn];
    } else {
        [_cameraHelper setCaptureTorchMode:AVCaptureTorchModeOff];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
