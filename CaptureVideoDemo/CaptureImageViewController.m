//
//  CaptureImageViewController.m
//  CaptureVideoDemo
//
//  Created by Jam on 16/5/26.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "CaptureImageViewController.h"
#import "JCCameraImageHelper.h"

@interface CaptureImageViewController ()

@property (nonatomic, strong) JCCameraImageHelper *cameraHelper;

@end

@implementation CaptureImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _cameraHelper = [[JCCameraImageHelper alloc] initWithCameraScanType:JCCameraScanImageType];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [_cameraHelper embedPreviewInView:self.view];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //实时取景
    [_cameraHelper startRunning];
    
    [_cameraHelper carmeraScanBlock:^(CIImage *image, NSString *qrContent, BOOL *isNextFilterImage){
        *isNextFilterImage = YES;
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
    [_cameraHelper swapFrontAndBackCameras];
}

@end
