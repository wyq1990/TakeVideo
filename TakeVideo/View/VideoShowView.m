//
//  VideoShowView.m
//  TakeVideo
//
//  Created by heyk on 20/4/16.
//  Copyright © 2016年 成都好房通股份科技有限公司. All rights reserved.
//

#import "VideoShowView.h"

static float kMaxScale = 5;// 最大放大倍数

@implementation VideoShowView {
    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
- (void)dealloc {
    
    NSLog(@"VideoShowView dealloc ====");
}

- (id)initWithFrame:(CGRect)frame maxDuraTime:(CGFloat)maxTime{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        
        self.maxDuraTime = maxTime;
        self.taker = [[VideoTaker alloc] init];
        self.taker.maxDuration = maxTime;
        self.taker.videoSize = frame.size;
        [self.layer addSublayer:_taker.preViewLayer];
        _taker.preViewLayer.frame = self.bounds;
        
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
        [self addGestureRecognizer:pinchRecognizer];
    }
    return self;
}

- (void)setCameraPostion:(CameraPosition)cameraPostion {
    _cameraPostion = cameraPostion;
    if (_taker) {
        [_taker setCameraPostion:cameraPostion];
    }
}

- (void)setBOpenFlash:(BOOL)bOpenFlash{
    _bOpenFlash = bOpenFlash;
    if (_taker) {
        [_taker setBOpenFlash:bOpenFlash];
    }
}

- (void)setDelegate:(id)delegate {
    
    _taker.delegate = delegate;
}

- (void)setMaxDuraTime:(CGFloat)maxDuraTime {
    _maxDuraTime = maxDuraTime;
    if (_taker) {
        _taker.maxDuration = maxDuraTime;
    }
}

- (void)setWaterImage:(UIImage *)waterImage {
    _waterImage = waterImage;
    if (_taker) {
        _taker.waterImage = waterImage;
    }
}

- (void)setWaterPosition:(WatermarkPosition)waterPosition {
    _waterPosition = waterPosition;
    if (_taker) {
        _taker.waterPosition = waterPosition;
    }
}

- (void)setVideoSize:(CGSize)videoSize {
    if (_taker) {
        _taker.videoSize = videoSize;
    }
}

- (void)scale:(id)sender {

    CGFloat scale = [(UIPinchGestureRecognizer*)sender scale];

    if (_taker) {
        
        if (scale > 1) {
             scale =[_taker currentVideoScale] + scale - 1;
        }
        else if(scale<=1){
            scale =[_taker currentVideoScale] - (1- scale);
        }
      
        if (scale<1.0) scale = 1.0;
        if (scale > kMaxScale) scale = kMaxScale;
        
        [_taker changeVideoScale:scale];
  
    }
}
@end
