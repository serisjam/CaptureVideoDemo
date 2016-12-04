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

- (void)startRunning;
- (void)stopRunning;

- (void)embedPreviewInView:(UIView *)aView;

//获取视频流其中的一帧或者成功扫描二维码
- (void)carmeraScanBlock:(JCCameraCallBacklBlock)cameraCallBacklBlock;

@end
