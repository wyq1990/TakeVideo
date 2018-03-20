//
//  VideoLoadingView.m
//  Erp4iOS
//
//  Created by 开发者 on 16/4/15.
//  Copyright © 2016年 成都好房通科技有限公司. All rights reserved.
//

#import "VideoLoadingView.h"
#import "Masonry.h"
#import <QuartzCore/QuartzCore.h>


@interface VideoLoadingView() {
    CGFloat fProgressWidth; // 动画背景图长度
    UIView *progressView;
}

@end


@implementation VideoLoadingView

- (id)init {
    self = [super init];
    if (self) {
        [self initUI];
        self.hidden = YES;
    }
    return self;
}

#pragma mark
#pragma mark-- UI初始化

- (void)initUI {
    fProgressWidth = 209.0 ;//进度条长度固定
    
    self.frame = CGRectMake(0, 0, fProgressWidth, 62);
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"视频加载_logo"]];
    [self addSubview:logoView];
    
    UIImageView *progressBackView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"视频播放加载条下"]];
    [self addSubview:progressBackView];
    
    progressView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"视频播放加载条上"]];
    [progressBackView addSubview:progressView];
    
    [logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY).offset(-22);
        make.width.equalTo(@156);
        make.height.equalTo(@38);
    }];
    
    [progressBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(logoView.mas_bottom).offset(22);
        make.width.equalTo([NSNumber numberWithFloat:fProgressWidth]);
        make.height.equalTo(@2);
        make.centerX.equalTo(self.mas_centerX);
    }];
    
    progressView.frame = CGRectMake(0, -3, 34, 8);
}

#pragma mark
#pragma mark-- 公共方法

- (void)startAnimation {
    self.hidden = NO;
    _bAnimation = YES;
    
    //动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = 1; // 持续时间
    animation.repeatCount = MAXFLOAT; // 重复次数
    animation.fromValue = [NSValue valueWithCGPoint:progressView.layer.position];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(fProgressWidth, progressView.layer.position.y)];
    [progressView.layer addAnimation:animation forKey:@"kMoveProgress"];
}


- (void)stopAnimation {
    self.hidden = YES;
    _bAnimation = NO;
    [progressView.layer removeAnimationForKey:@"kMoveProgress"];
}


@end
