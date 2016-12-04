//
//  JCCameraImageHelper.h
//  MYLabor
//
//  Created by 贾淼 on 15-6-23.
//  Copyright (c) 2015年 milestone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, JCCameraScanType) {
    JCCameraScanCodeType,
    JCCameraScanImageType
};

typedef void(^JCCameraCallBacklBlock)(UIImage *image, NSString *qrContent, BOOL *isNextFilterImage);

@interface JCCameraImageHelper : NSObject

- (id)initWithCameraScanType:(JCCameraScanType)cameraScanType;

//闪光灯模式，默认打开自动模式
@property (nonatomic, assign) AVCaptureTorchMode captureTorchMode;
//扫描区域,默认居中扫描
@property (nonatomic, assign) CGRect scanRect;
//是否开启扫描框，默认开启
@property (nonatomic, assign) BOOL isAvailable;

- (void)startRunning;
- (void)stopRunning;

- (void)embedPreviewInView:(UIView *)aView;

//获取视频流其中的一帧或者成功扫描二维码
- (void)carmeraScanBlock:(JCCameraCallBacklBlock)cameraCallBacklBlock;

@end
