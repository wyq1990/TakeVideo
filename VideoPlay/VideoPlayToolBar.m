//
//  VideoPlayToolBar.m
//  Erp4iOS
//
//  Created by 开发者 on 16/4/12.
//  Copyright © 2016年 成都好房通科技有限公司. All rights reserved.
//

#import "VideoPlayToolBar.h"
#import "Masonry.h"

static int kAutoHiddenTime = 5;//自动隐藏工具栏的时间 1

@interface VideoPlayToolBar(){
    
    UIButton *playButton_;
    UIButton *fullScreenButton;
    UILabel *leftPlayTimeLabel;//左边播放时间
    UILabel *rightAllTimeLabel;//右边总时间
    UIProgressView *progress;
    
    NSTimer *timer;// 用于自动隐藏计数
    
}

@end


@implementation VideoPlayToolBar

- (void)dealloc{
    
    if (timer && [timer isValid]) {
        [timer invalidate];
    }
    
    NSLog(@"VideoPlayToolBar == 释放");
}

- (id)init{
    
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.0
                                               green:0.0
                                                blue:0.0
                                               alpha:0.5];;
        fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *fullScreenImage = [UIImage imageNamed:@"放大"];
        [fullScreenButton setImage:fullScreenImage forState:UIControlStateNormal];
        [fullScreenButton addTarget:self action:@selector(clickScreen:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:fullScreenButton];
        
        playButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *playImage = [UIImage imageNamed:@"播放"];
        [playButton_ setImage:playImage forState:UIControlStateNormal];
        [playButton_ addTarget:self action:@selector(clickPlay:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:playButton_];
        
        
        rightAllTimeLabel = [[UILabel alloc] init];
        rightAllTimeLabel.textColor = [UIColor colorWithRed:153.0/255
                                                      green:153.0/255
                                                       blue:153.0/255
                                                      alpha:1];
        
        rightAllTimeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12];
        [rightAllTimeLabel sizeToFit];
        rightAllTimeLabel.text = @"00:00";
        [self addSubview:rightAllTimeLabel];
        
        leftPlayTimeLabel = [[UILabel alloc] init];
        leftPlayTimeLabel.textColor = [UIColor colorWithRed:153.0/255
                                                      green:153.0/255
                                                       blue:153.0/255
                                                      alpha:1];
        leftPlayTimeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12];
        leftPlayTimeLabel.text = @"00:00";
        [self addSubview:leftPlayTimeLabel];
        
        
        self.slider = [[UISlider alloc] init];
        [_slider resignFirstResponder];
        _slider.maximumTrackTintColor = [UIColor clearColor];
        _slider.minimumTrackTintColor = [UIColor colorWithRed:40.0/255
                                                        green:169.0/255
                                                         blue:94.0/255
                                                        alpha:1];;
        _slider.maximumValue = 0;
        _slider.minimumValue = 0;

        [_slider addTarget:self
                    action:@selector(changingSlideValue:)
          forControlEvents:UIControlEventValueChanged];
        
        [_slider addTarget:self
                    action:@selector(changingSlideValue:)
          forControlEvents:UIControlEventTouchDown];
        
        [_slider addTarget:self
                    action:@selector(didEndChangeSlider)
          forControlEvents:UIControlEventTouchCancel];
        
        [_slider addTarget:self
                    action:@selector(didEndChangeSlider)
          forControlEvents:UIControlEventTouchUpInside];
        
        [_slider addTarget:self
                    action:@selector(didEndChangeSlider)
          forControlEvents:UIControlEventTouchUpOutside];
   
        
        [_slider setThumbImage:[UIImage imageNamed:@"xdot"]
                      forState:UIControlStateNormal];
        [self addSubview:_slider];
        
        
        progress = [[UIProgressView alloc] init];
        progress.progress = 0;
        progress.progressTintColor = [UIColor colorWithRed:102.0/255
                                                     green:102.0/255
                                                      blue:102.0/255
                                                     alpha:1];
        
        progress.trackTintColor = [UIColor colorWithRed:45.0/255
                                                  green:45.0/255
                                                   blue:45.0/255
                                                  alpha:0.5];;
        [_slider insertSubview:progress atIndex:0];
        
        
        //布局
        float fullScreenButtonWidth = 20 + fullScreenImage.size.width;
        [fullScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right);
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
            make.width.equalTo([NSNumber numberWithFloat:fullScreenButtonWidth]);
        }];
        
        float playButtonWidth = 20 + playImage.size.width;
        [playButton_ mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
            make.width.equalTo([NSNumber numberWithFloat:playButtonWidth]);
        }];
        
        
        
        [leftPlayTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(playButton_.mas_right);
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
        }];
        
        [rightAllTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(fullScreenButton.mas_left);
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
        }];
        [_slider mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(rightAllTimeLabel.mas_left).offset(-10);
            make.left.equalTo(leftPlayTimeLabel.mas_right).offset(10);
            make.center.equalTo(self);
        }];
        
        [progress mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_slider.mas_right);
            make.left.equalTo(_slider.mas_left);
            make.centerY.equalTo(_slider.mas_centerY).offset(1);
            
        }];
    }
    return self;
}

- (void)didAddSubview:(UIView *)subview {
    [super didAddSubview:subview];
    [self starTimer];
}

#pragma mark
#pragma mark-- 私有方法
- (void)showWithAnimation {
    self.hidden = NO;
    [UIView animateWithDuration:0.25
                     animations:^{
                         
                         self.alpha = 1;
                         
                     } completion:^(BOOL finished) {
                         
                         [self starTimer];
                     }];
    
}

- (void)hiddenWithAnimatin {
    if (timer && [timer isValid]) {
        [timer invalidate];
    }
    [UIView animateWithDuration:0.25
                     animations:^{
                         
                         self.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         self.hidden = YES;
                     }];
    
}


- (void)showOrHidden {
    if (self.hidden) {
        
        [self showWithAnimation];
    }
    else{
        [self hiddenWithAnimatin];
    }
}

//启动计数器
- (void)starTimer {
    if (timer && [timer isValid]) {
        
        [timer invalidate];
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:kAutoHiddenTime
                                             target:self
                                           selector:@selector(hiddenWithAnimatin)
                                           userInfo:nil
                                            repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
}

// 停止计时器
- (void)stopTimer {
    if (timer && [timer isValid]) {
        
        [timer invalidate];
    }
}

- (void)setTotleTime:(float)time {
    rightAllTimeLabel.text =  [self convertTime:time];
}

#pragma mark
#pragma mark-- 公共方法

- (void)setplayedTime:(float)time {
    leftPlayTimeLabel.text = [self convertTime:time+0.1];
}

- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}

- (CGFloat)converTimeStringToSecond:(NSString*)str {
    
    NSArray *array = [str componentsSeparatedByString:@":"];
    
    float intervel = 0;
    for (int i = 0; i<array.count; i++) {
        int t = [[array objectAtIndex:i] intValue] * pow(60, array.count - i - 1);
        intervel = intervel + t;
    }
    return intervel;
}

- (float)currentProgress {
    
    CGFloat sec = [self converTimeStringToSecond:leftPlayTimeLabel.text];
    
    return  sec; //self.slider.value - (int)_slider.value > 0.5 ? self.slider.value+1:self.slider.value ;
}


- (void)setCacheProgress:(float)p {
    float value = p / _slider.maximumValue;
    progress.progress = value;
}

#pragma mark
#pragma mark-- 滑动进度条相关响应

- (void)changingSlideValue:(UISlider*)aslider {
    if (aslider.maximumValue == aslider.minimumValue) { //如果视频总时间没用拿到就不能滑动
        return;
    }
    [self stopTimer];
     _isPlaying = NO;
    
    if (_delegate && [_delegate respondsToSelector:@selector(changeProgress:)]) {
        [_delegate changeProgress:aslider.value];
    }
    [self setplayedTime:aslider.value];
    
}

- (void)didEndChangeSlider {
    if (_slider.maximumValue == _slider.minimumValue) { //如果视频总时间没用拿到就不能滑动
        return;
    }
    
    [self starTimer];
  //  _isPlaying = YES;
    
    if (_delegate && [_delegate respondsToSelector:@selector(didEndChangeProgress)]) {
        [_delegate didEndChangeProgress];
    }
}

#pragma mark
#pragma mark-- 全屏或者退出全屏

- (void)showFullStatus {
    fullScreenButton.selected = YES;
    [fullScreenButton setImage:[UIImage imageNamed:@"缩放"] forState:UIControlStateNormal];
}

- (void)showMinStatus {
    fullScreenButton.selected = NO;
    [fullScreenButton setImage:[UIImage imageNamed:@"放大"] forState:UIControlStateNormal];
}

- (void)clickScreen:(UIButton*)button {
    
    if (!button.selected) {//全屏
        [self showFullStatus];
        
        if (_delegate && [_delegate respondsToSelector:@selector(showFullScreen)]) {
            [_delegate showFullScreen];
        }
    }
    else{
        [self showMinStatus];
        if (_delegate && [_delegate respondsToSelector:@selector(hiddenFullScreen)]) {
            [_delegate hiddenFullScreen];
        }
    }
}


#pragma mark
#pragma mark-- 暂停或者播放

- (void)play {
    _isPlaying = YES;
    playButton_.selected = YES;
    [playButton_ setImage:[UIImage imageNamed:@"暂停"]
                 forState:UIControlStateNormal];
    
    if (self.delegate && [_delegate respondsToSelector:@selector(startPlay)]) {
        [self.delegate startPlay];
    }
}


- (void)pause {
    _isPlaying = NO;
    playButton_.selected = NO;
    [playButton_ setImage:[UIImage imageNamed:@"播放"]
                 forState:UIControlStateNormal];
    
    if (self.delegate && [_delegate respondsToSelector:@selector(pause)]) {
        [self.delegate pause];
    }
}

// 点击播放按钮
- (void)clickPlay:(UIButton*)button {
    button.selected = !button.selected;
    
    if (button.selected) {//播放
        [self play];
    }
    else{//暂停
        [self pause];
    }
}

@end
