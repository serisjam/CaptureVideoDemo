//
//  JCH264Encoder.h
//  CaptureVideoDemo
//
//  Created by seris-Jam on 16/6/23.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>

/// 视频质量
typedef NS_ENUM(NSUInteger, JCLiveVideoQuality){
    /// 分辨率： 360 *640 帧数：15 码率：500Kps
    JCLiveVideoQuality_Low1 = 0,
    /// 分辨率： 360 *640 帧数：24 码率：800Kps
    JCLiveVideoQuality_Low2 = 1,
    /// 分辨率： 360 *640 帧数：30 码率：800Kps
    JCLiveVideoQuality_Low3 = 2,
    /// 分辨率： 540 *960 帧数：15 码率：800Kps
    JCLiveVideoQuality_Medium1 = 3,
    /// 分辨率： 540 *960 帧数：24 码率：800Kps
    JCLiveVideoQuality_Medium2 = 4,
    /// 分辨率： 540 *960 帧数：30 码率：800Kps
    JCLiveVideoQuality_Medium3 = 5,
    /// 分辨率： 720 *1280 帧数：15 码率：1000Kps
    JCLiveVideoQuality_High1 = 6,
    /// 分辨率： 720 *1280 帧数：24 码率：1200Kps
    JCLiveVideoQuality_High2 = 7,
    /// 分辨率： 720 *1280 帧数：30 码率：1200Kps
    JCLiveVideoQuality_High3 = 8,
    /// 默认配置
    JCLiveVideoQuality_Default = JCLiveVideoQuality_Low2
};

@protocol JCH264EncoderDelegate <NSObject>

- (void)getSpsData:(NSData *)spsData withPpsData:(NSData *)ppsData;
- (void)getEncodedData:(NSData *)data isKeyFrame:(BOOL)isKeyFrame;

@end


@interface JCH264Encoder : NSObject

@property (nonatomic, weak) id<JCH264EncoderDelegate> delegate;

- (instancetype)initWithJCLiveVideoQuality:(JCLiveVideoQuality)liveVideoQuality;

- (void)changeJCLiveVideoQuality:(JCLiveVideoQuality)liveVideoQuality;

- (void)encodeVideoData:(CMSampleBufferRef)pixelBuffer timeStamp:(uint64_t)timeStamp;

- (void)endVideoCompression;

@end
