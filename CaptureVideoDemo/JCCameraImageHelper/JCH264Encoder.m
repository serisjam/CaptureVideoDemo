//
//  JCH264Encoder.m
//  CaptureVideoDemo
//
//  Created by seris-Jam on 16/6/23.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "JCH264Encoder.h"

@interface JCLiveVideoproperties : NSObject

/// 视频分辨率宽
@property (nonatomic, assign) NSInteger width;

/// 视频分辨率高
@property (nonatomic, assign) NSInteger height;

/// 视频的帧率，即 fps
@property (nonatomic, assign) NSUInteger videoFrameRate;

/// 视频的最大帧率，即 fps
@property (nonatomic, assign) NSUInteger videoMaxFrameRate;

/// 视频的最小帧率，即 fps
@property (nonatomic, assign) NSUInteger videoMinFrameRate;

/// 最大关键帧间隔，可设定为 fps 的2倍，影响一个 gop 的大小
@property (nonatomic, assign) NSUInteger videoMaxKeyframeInterval;

/// 视频的码率，单位是 bps
@property (nonatomic, assign) NSUInteger videoBitRate;

/// 视频的最大码率，单位是 bps
@property (nonatomic, assign) NSUInteger videoMaxBitRate;

/// 视频的最小码率，单位是 bps
@property (nonatomic, assign) NSUInteger videoMinBitRate;

- (instancetype)initWithJCLiveVideoQuality:(JCLiveVideoQuality)liveVideoQuality;

@end

@implementation JCLiveVideoproperties

- (instancetype)initWithJCLiveVideoQuality:(JCLiveVideoQuality)liveVideoQuality {
    self = [super init];
    
    if (self) {
        [self configPropertiesWithJCLiveVideoQuality:liveVideoQuality];
    }
    
    return self;
}

- (void)configPropertiesWithJCLiveVideoQuality:(JCLiveVideoQuality)liveVideoQuality {
    switch (liveVideoQuality) {
        case JCLiveVideoQuality_Low1: {
            self.width = 360;
            self.height = 640;
            self.videoFrameRate = 15;
            self.videoMaxFrameRate = 15;
            self.videoMinFrameRate = 10;
            self.videoBitRate = 500 * 1024;
            self.videoMaxBitRate = 600 * 1024;
            self.videoMinBitRate = 250 * 1024;
        }
            break;
        case JCLiveVideoQuality_Low2: {
            self.width = 360;
            self.height = 640;
            self.videoFrameRate = 24;
            self.videoMaxFrameRate = 24;
            self.videoMinFrameRate = 12;
            self.videoBitRate = 800 * 1024;
            self.videoMaxBitRate = 900 * 1024;
            self.videoMinBitRate = 500 * 1024;
            
        }
            break;
        case JCLiveVideoQuality_Low3: {
            self.width = 360;
            self.height = 640;
            self.videoFrameRate = 30;
            self.videoMaxFrameRate = 30;
            self.videoMinFrameRate = 15;
            self.videoBitRate = 800 * 1024;
            self.videoMaxBitRate = 900 * 1024;
            self.videoMinBitRate = 500 * 1024;
        }
            break;
        case JCLiveVideoQuality_Medium1: {
            self.width = 540;
            self.height = 960;
            self.videoFrameRate = 30;
            self.videoMaxFrameRate = 30;
            self.videoMinFrameRate = 15;
            self.videoBitRate = 800 * 1024;
            self.videoMaxBitRate = 900 * 1024;
            self.videoMinBitRate = 500 * 1024;
            
        }
            break;
        case JCLiveVideoQuality_Medium2: {
            
        }
            break;
        case JCLiveVideoQuality_Medium3: {
            
        }
            break;
        case JCLiveVideoQuality_High1: {
            
        }
            break;
        case JCLiveVideoQuality_High2: {
            
        }
            break;
        case JCLiveVideoQuality_High3: {
            
        }
            break;
        default:
            break;
    }
}

@end

@interface JCH264Encoder ()

@property (nonatomic, assign) VTCompressionSessionRef compressionSession;
@property (nonatomic, strong) NSData *sps;
@property (nonatomic, strong) NSData *pps;

@property (nonatomic, assign) NSInteger frameCount;

@property (nonatomic, assign) BOOL enbaleWriteVideoFile;

@end

@implementation JCH264Encoder

- (instancetype)initWithJCLiveVideoQuality:(JCLiveVideoQuality)liveVideoQuality {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (instancetype)initEncodeWidth:(int)width withHeight:(int)height {
    self = [super init];
    
    if (self) {
        self.compressionSession = nil;
        self.sps = nil;
        self.pps = nil;
        _frameCount = 0;
        
#ifdef DEBUG
        self.enbaleWriteVideoFile = YES;
#endif
        
        NSDictionary* pixelBufferOptions = @{ (NSString*) kCVPixelBufferPixelFormatTypeKey : //@(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange),
                                              @(kCVPixelFormatType_32BGRA),
                                              (NSString*) kCVPixelBufferWidthKey : @(width),
                                              (NSString*) kCVPixelBufferHeightKey : @(height),
                                              (NSString*) kCVPixelBufferOpenGLESCompatibilityKey : @YES,
                                              (NSString*) kCVPixelBufferIOSurfacePropertiesKey : @{}};
        
        OSStatus status = VTCompressionSessionCreate(NULL, width, height, kCMVideoCodecType_H264, NULL, (__bridge CFDictionaryRef)pixelBufferOptions, NULL, &VideoCompressonOutputCallback, (__bridge void*)self, &_compressionSession);
        
        if (status != 0) {
            NSLog(@"VTCompressionSessionCreate error");
        }
        
        status = VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, (__bridge CFTypeRef)@(60));
        status = VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration, (__bridge CFTypeRef)@(2));
        status = VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_AverageBitRate, (__bridge CFTypeRef)@(800*1024));
        NSArray *dataLimits = @[@(150*1024), @(1)];
        status = VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_DataRateLimits, (__bridge CFArrayRef)dataLimits);
        status = VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_Quality, (__bridge CFTypeRef)@(1.0));
        status = VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_MoreFramesBeforeStart, kCFBooleanTrue);
        status = VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_MoreFramesAfterEnd, kCFBooleanTrue);
        status = VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Main_AutoLevel);
        status = VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_H264EntropyMode, kVTH264EntropyMode_CABAC);
        status = VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_MaxFrameDelayCount, (__bridge CFTypeRef)@(15));
        status = VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_RealTime, kCFBooleanFalse);
        status = VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_ExpectedFrameRate, (__bridge CFTypeRef)@(30));
        
        VTCompressionSessionPrepareToEncodeFrames(_compressionSession);
    }
    
    return self;
}

#pragma mark -- VideoCompressonCallBack
static void VideoCompressonOutputCallback(void *outputCallbackRefCon, void *sourceFrameRefCon, OSStatus status, VTEncodeInfoFlags infoFlags, CMSampleBufferRef sampleBuffer) {
    if (status != 0) {
        return ;
    }
    
    if (!CMSampleBufferDataIsReady(sampleBuffer)) {
        return;
    }
    
    CFArrayRef sampleBufferInfoArrary = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true);
    if (!sampleBufferInfoArrary) {
        return;
    }
    
    CFDictionaryRef dic = (CFDictionaryRef)CFArrayGetValueAtIndex(sampleBufferInfoArrary, 0);
    if (!dic) {
        return;
    }
    
    JCH264Encoder* encoder = (__bridge JCH264Encoder*)outputCallbackRefCon;
    
    BOOL isKeyFrame = !CFDictionaryContainsKey(dic, kCMSampleAttachmentKey_NotSync);
    
    if (isKeyFrame) {
        CMFormatDescriptionRef formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer);
        size_t sparameterSetSize, sparameterSetCount;
        const uint8_t *sparameterSet;
        
        OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(formatDesc, 0, &sparameterSet, &sparameterSetSize, &sparameterSetCount, 0);
    
        if (statusCode == noErr) {
            size_t pparameterSetSize, pparameterSetCount;
            const uint8_t *pparameterSet;
            
            OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(formatDesc, 1, &pparameterSet, &pparameterSetSize, &pparameterSetCount, 0);
            
            if (statusCode == noErr) {
                encoder.sps = [NSData dataWithBytes:sparameterSet length:sparameterSetSize];
                encoder.pps = [NSData dataWithBytes:pparameterSet length:pparameterSetSize];
                
                if ([encoder.delegate respondsToSelector:@selector(getSpsData:withPpsData:)]) {
                    [encoder.delegate getSpsData:encoder.sps withPpsData:encoder.pps];
                }
            }
        }
    }
    
    CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    
    size_t length, totalLength;
    char *dataPointer;
    
    OSStatus statusCode = CMBlockBufferGetDataPointer(dataBuffer, 0, &length, &totalLength, &dataPointer);
    
    if (statusCode == noErr) {
        
        size_t bufferOffset = 0;
        
        static const int AVCCHeaderLength = 4;
        
        while (bufferOffset < totalLength - AVCCHeaderLength) {
            
            uint32_t NALUnitLength = 0;
            memcpy(&NALUnitLength, dataPointer+bufferOffset, AVCCHeaderLength);
            
            NALUnitLength = CFSwapInt32BigToHost(NALUnitLength);
            
            NSData *data = [[NSData alloc] initWithBytes:dataPointer+bufferOffset+AVCCHeaderLength length:NALUnitLength];
            
            if ([encoder.delegate respondsToSelector:@selector(getEncodedData:isKeyFrame:)]) {
                [encoder.delegate getEncodedData:data isKeyFrame:isKeyFrame];
            }
            
            bufferOffset += AVCCHeaderLength + NALUnitLength;
        }
        
    }
    
    
}

#pragma mark -VideoCompressEncoder
- (void)encodeVideoData:(CMSampleBufferRef)pixelBuffer timeStamp:(uint64_t)timeStamp{
    CVImageBufferRef imageBuffer = (CVImageBufferRef)CMSampleBufferGetImageBuffer(pixelBuffer);
    _frameCount++;
    CMTime presentationTimeStamp = CMTimeMake(_frameCount, 1000);
    CMTime duration = CMTimeMake(1, (int32_t)30);
    
    NSDictionary *prorperties = nil;
    if (_frameCount % (int32_t)60 == 0) {
        prorperties = @{(__bridge NSString *)kVTEncodeFrameOptionKey_ForceKeyFrame : @YES};
    }
    
    NSNumber *timeNumber = @(timeStamp);
    VTEncodeInfoFlags flags;
    VTCompressionSessionEncodeFrame(_compressionSession, imageBuffer, presentationTimeStamp, duration, (__bridge CFDictionaryRef)prorperties, (__bridge_retained void *)timeNumber, &flags);
}

- (void)endVideoCompression {
    VTCompressionSessionCompleteFrames(_compressionSession, kCMTimeInvalid);
}

@end
