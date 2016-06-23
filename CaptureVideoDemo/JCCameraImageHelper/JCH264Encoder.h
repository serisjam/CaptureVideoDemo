//
//  JCH264Encoder.h
//  CaptureVideoDemo
//
//  Created by seris-Jam on 16/6/23.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>

@protocol JCH264EncoderDelegate <NSObject>

- (void)getSpsData:(NSData *)spsData withPpsData:(NSData *)ppsData;
- (void)getEncodedData:(NSData *)data isKeyFrame:(BOOL)isKeyFrame;

@end

@interface JCH264Encoder : NSObject

@property (nonatomic, weak) id<JCH264EncoderDelegate> delegate;

- (instancetype)initEncodeWidth:(int)width withHeight:(int)height;

- (void)encodeVideoData:(CMSampleBufferRef)pixelBuffer timeStamp:(uint64_t)timeStamp;

- (void)endVideoCompression;

@end
