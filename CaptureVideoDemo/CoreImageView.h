//
//  CoreImageView.h
//  CaptureVideoDemo
//
//  Created by Jam on 16/5/26.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface CoreImageView : GLKView

@property (nonatomic, strong) CIContext *coreImageContext;
@property (nonatomic, strong) CIImage *image;

@end
