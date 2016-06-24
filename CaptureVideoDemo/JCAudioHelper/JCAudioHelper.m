//
//  JCAudioHelper.m
//  CaptureVideoDemo
//
//  Created by seris-Jam on 16/6/24.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "JCAudioHelper.h"

@interface JCAudioHelper ()

@property (nonatomic, strong) AVAudioSession *audioSession;

@end

@implementation JCAudioHelper

- (instancetype)initWithAudioType:(JCAudioType)audioType {
    self = [super init];
    
    if (self) {
        [self configSessionWithAudioType:audioType];
    }
    
    return self;
}

- (void)startRunning {
    
}

- (void)stopRunning {
    
}

#pragma mark private method

- (void)configSessionWithAudioType:(JCAudioType)audioType {
    
    self.audioSession = [AVAudioSession sharedInstance];
    
    switch (audioType) {
        case JCAudioPlayType:
            
            break;
        case JCAudioRecordType:
            
            break;
        case JCAudioPlayAndRecordType:
            [self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
            break;
        default:
            break;
    }
    
    
    BOOL isActive = [self.audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    
}

@end
