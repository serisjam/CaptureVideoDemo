//
//  CoreImageView.m
//  CaptureVideoDemo
//
//  Created by Jam on 16/5/26.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "CoreImageView.h"

@implementation CoreImageView

- (instancetype)initWithFrame:(CGRect)frame {
    EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    return [self initWithFrame:frame context:eaglContext];
}

- (instancetype)initWithFrame:(CGRect)frame context:(EAGLContext *)context {
    self.coreImageContext = [CIContext contextWithEAGLContext:context];
    
    self = [super initWithFrame:frame context:context];
    
    if (self) {
        self.enableSetNeedsDisplay = false;
    }
    
    return self;
}

- (void)setImage:(CIImage *)image {
    _image = image;
    [self display];
}

- (void)drawRect:(CGRect)rect {
    CGFloat scale = [self.window screen].scale;
    
    CGRect destRect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(scale, scale));
    [self.coreImageContext drawImage:_image inRect:destRect fromRect:_image.extent];
}

@end
