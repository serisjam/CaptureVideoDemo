//
//  JCCameraImageHelper.h
//  MYLabor
//
//  Created by 贾淼 on 15-6-23.
//  Copyright (c) 2015年 milestone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>

typedef NS_ENUM(NSInteger, JCCameraScanType) {
    JCCameraScanOriginType,
    JCCameraScanQRType,
    JCCameraScanImageType
};

typedef void(^cameraCallBacklBlock)(CIImage *image, NSString *qrContent, BOOL *isNextFilterImage);
typedef void(^cameraCaptureOriginDataBlock)(CMSampleBufferRef sampleBufferRef);

@interface JCCameraImageHelper : NSObject

- (id)initWithCameraScanType:(JCCameraScanType)cameraScanType;

- (void)startRunning;
- (void)stopRunning;

- (void)embedPreviewInView:(UIView *)aView;

//获取视频流其中的一帧或者成功扫描二维码
- (void)carmeraScanBlock:(cameraCallBacklBlock)cameraCallBacklBlock;
- (void)swapFrontAndBackCameras;

//获取原始视频流
- (void)carmeraScanOriginBlock:(cameraCaptureOriginDataBlock)cameraCaptureOriginBlock;

@end
