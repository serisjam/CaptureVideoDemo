//
//  ViewController.m
//  CaptureVideoDemo
//
//  Created by Jam on 16/5/26.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "ViewController.h"
#import "JCCameraImageHelper.h"
#import "CoreImageView.h"

@interface ViewController ()

@property (nonatomic, strong) JCCameraImageHelper *cameraHelper;
@property (nonatomic, strong) CoreImageView *coreImageView;

@end

@implementation ViewController

- (void)loadView {
    self.coreImageView = [[CoreImageView alloc] initWithFrame:CGRectZero];
    
    self.view = self.coreImageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _cameraHelper = [[JCCameraImageHelper alloc] initWithCameraScanType:JCCameraScanImageType];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
//    [_cameraHelper embedPreviewInView:self.view];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //实时取景
    [_cameraHelper startRunning];
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [weakSelf.cameraHelper carmeraScanBlock:^(CIImage *image, NSString *qrContent, BOOL *isNextFilterImage){
            CIFilter *filter = [CIFilter filterWithName:@"CIHueAdjust" withInputParameters:@{kCIInputAngleKey:@([weakSelf getRadius]),
                                                                                             kCIInputImageKey:image}];
            
            weakSelf.coreImageView.image = [filter outputImage];
            *isNextFilterImage = YES;
        }];
    });
    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (double)getRadius {
    double time = [[NSDate date] timeIntervalSinceReferenceDate];
    return  time*M_PI*2;
}

@end
