//
//  JCAudioHelper.h
//  CaptureVideoDemo
//
//  Created by seris-Jam on 16/6/24.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, JCAudioType) {
    JCAudioPlayType,
    JCAudioRecordType,
    JCAudioPlayAndRecordType
};

@interface JCAudioHelper : NSObject

- (instancetype)initWithAudioType:(JCAudioType)audioType;

- (void)startRunning;
- (void)stopRunning;

@end
