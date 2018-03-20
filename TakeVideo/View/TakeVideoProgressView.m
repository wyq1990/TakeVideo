//
//  TakeVideoProgressView.m
//  TakeVideo
//
//  Created by heyk on 20/4/16.
//  Copyright © 2016年 成都好房通股份科技有限公司. All rights reserved.
//

#import "TakeVideoProgressView.h"
#import "Masonry.h"
#import <QuartzCore/QuartzCore.h>
#import "GCDTimer.h"
#import "RecordTimeTipView.h"

@interface MyProgressView : UIView
@property (nonatomic, assign) CGFloat time;// 视频长度
@end

@implementation MyProgressView

@end


@interface TakeVideoProgressView()

@property (nonatomic, strong) UIImageView *progressIndicator;
@property (nonatomic, strong) RecordTimeTipView *tipView;
@property (nonatomic, assign) CGFloat minDuration;// 最短录制时间
@property (nonatomic, assign) CGFloat maxDuration;// 最长录制时间
@property (nonatomic, strong) NSMutableArray *progressViewArray;
@property (nonatomic, strong) NSString * shiningTimer;

@end

@implementation TakeVideoProgressView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)dealloc {
    [self stopIndicatorAnimation];
    NSLog(@"TakeVideoProgressView dealloc ====");
}

- (id)initWithframe:(CGRect)frame
        minDuration:(CGFloat)minDuration
        maxDuration:(CGFloat)maxDuration {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultData];
        self.minDuration = minDuration;
        self.maxDuration = maxDuration;
        [self createMinRecoredLine];
    }
    return self;
}

#pragma mark
#pragma mark-- 自定义方法
//默认属性
- (void)defaultData {
    self.minDuration = 10;
    self.maxDuration = 40;
    self.tinColor = [UIColor lightGrayColor];
    self.trackColor = [UIColor greenColor];
    self.sperateLineColor = [UIColor grayColor];
    self.minTimeLineColor = [UIColor blackColor];
    self.timeTipColor = self.trackColor;
    self.willDeleteColor = [UIColor redColor];
    self.totalDuration = 0;
    
    self.progressViewArray = [[NSMutableArray alloc] init];
}

- (void)createMinRecoredLine {
    
    UIView *speartLine = [self viewWithTag:100];
    if (!speartLine) {
        speartLine = [[UIView alloc] init];
        speartLine.tag = 100;
        [self addSubview:speartLine];
    }
    speartLine.backgroundColor = _minTimeLineColor;
    [speartLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        float percernt = _minDuration / _maxDuration * self.frame.size.width;
        make.left.equalTo(self.mas_left).offset(percernt);
        make.width.equalTo(@1);
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
    }];
    
    //indicator
    self.progressIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 5 , self.frame.size.height)];
    _progressIndicator.backgroundColor = [UIColor whiteColor];
    [self addSubview:_progressIndicator];
    [self starIndicatorAniamtion];
    
    self.tipView = [[RecordTimeTipView alloc] initWithFrame:CGRectZero];
    [self addSubview:_tipView];
    _tipView.hidden = YES;
    
    [_tipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self.mas_bottom);
        make.height.equalTo(@25);
    }];
}



#pragma mark
#pragma mark--  自定义方法
- (void)starIndicatorAniamtion {
    self.shiningTimer = @"shiningTimer";
    __weak typeof(self) weakSelf = self;
    [[GCDTimer sharedInstance] scheduledDispatchTimerWithName:_shiningTimer
                                                 timeInterval:1
                                                        queue:nil
                                                      repeats:YES
                                                 actionOption:AbandonPreviousAction
                                                       action:^{
                                                           [weakSelf onTimer];
                                                       }];
    
    
}

- (void)stopIndicatorAnimation {
    [[GCDTimer sharedInstance]cancelTimerWithName:_shiningTimer];
}

- (void)hiddenIndicator {
    [self stopIndicatorAnimation];
    _progressIndicator.hidden = YES;
}

- (void)showIndicator {
    [self refreshIndicatorPosition];
    [self starIndicatorAniamtion];
    _progressIndicator.hidden = NO;
}


- (void)onTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5  animations:^{
            _progressIndicator.alpha = 0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5  animations:^{
                _progressIndicator.alpha = 1;
            }];
        }];
    });
}
#pragma mark
#pragma mark-- 公共方法
- (void)setMinDuration:(CGFloat)minDuration
           maxDuration:(CGFloat)maxDuration {
    self.minDuration = minDuration;
    self.maxDuration = maxDuration;
    [self createMinRecoredLine];
}

- (void)setLastProgressToStyle:(ProgressBarProgressStyle)style {
    
    UIView *lastProgressView = [_progressViewArray lastObject];
    if (!lastProgressView) {
        return;
    }
    
    switch (style) {
        case ProgressBarProgressStyleDelete:
        {
            lastProgressView.backgroundColor = _willDeleteColor;
            _progressIndicator.hidden = YES;
            [self hiddenIndicator];
        }
            break;
        case ProgressBarProgressStyleNormal:
        {
            lastProgressView.backgroundColor = _trackColor;
            _progressIndicator.hidden = NO;
        }
            break;
        default:
            break;
    }
}

- (void)addProgressView {
    MyProgressView *lastProgressView = [_progressViewArray lastObject];
    [self setLastProgressToStyle:ProgressBarProgressStyleNormal];
    
    CGFloat newProgressX = 0.0f;
    
    if (lastProgressView) {
        CGRect frame = lastProgressView.frame;
        frame.size.width -= 1;
        lastProgressView.frame = frame;
        
        newProgressX = frame.origin.x + frame.size.width + 1;
    }
    
    MyProgressView *newProgressView = [[MyProgressView alloc] initWithFrame:CGRectMake(newProgressX, 0, 1, self.frame.size.height)];
    newProgressView.backgroundColor = _trackColor;
    newProgressView.time = 0;
    [self addSubview:newProgressView];
    
    [_progressViewArray addObject:newProgressView];
}

- (void)setLastProgressToWidth:(CGFloat)width
                      lastTime:(CGFloat)lastTime
                     totleTime:(CGFloat)totalTime {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // 改变progress长度
        MyProgressView *lastProgressView = [_progressViewArray lastObject];
        if (!lastProgressView) {
            return;
        }
        lastProgressView.time = lastTime;
        
        CGRect frame = lastProgressView.frame;
        frame.size.width = width;
        lastProgressView.frame = frame;
        self.totalDuration = totalTime;
        
        // 修改白点位置
        [self refreshIndicatorPosition];
        // 修改tip内容
        [self refreshTipUI];
        
    });
}

// 属性时间tip
- (void)refreshTipUI{
    UIView *lastProgressView = [_progressViewArray lastObject];
    if (!lastProgressView) {
        _tipView.hidden = YES;
        return;
    }
    [_tipView setCurrentSeconds:_totalDuration];
    
    _tipView.hidden = NO;
    
    float totalWidth = lastProgressView.frame.origin.x + lastProgressView.frame.size.width;
    // 判断tip位置和方向
    if (totalWidth > self.frame.size.width *0.6) {
        [_tipView showRightTip];
        [_tipView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_left).offset(totalWidth);
            make.top.equalTo(self.mas_bottom);
            make.height.equalTo(@25);
        }];
    }
    else{
        [_tipView showLeftTip];
        [_tipView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(totalWidth);
            make.top.equalTo(self.mas_bottom);
            make.height.equalTo(@25);
        }];
    }
}

- (void)refreshIndicatorPosition {
    UIView *lastProgressView = [_progressViewArray lastObject];
    if (!lastProgressView) {
        _progressIndicator.center = CGPointMake(0, self.frame.size.height / 2);
        return;
    }
    _progressIndicator.center = CGPointMake(MIN(lastProgressView.frame.origin.x + lastProgressView.frame.size.width, self.frame.size.width - _progressIndicator.frame.size.width / 2 + 2), self.frame.size.height / 2);
}

- (void)removeLastProgressView {
    if (_progressViewArray.count <= 0) {
        return;
    }
    MyProgressView *lastProgressView = [_progressViewArray lastObject];
    
    self.totalDuration = _totalDuration - lastProgressView.time;
    [lastProgressView removeFromSuperview];
    [_progressViewArray removeLastObject];
    
    [self showIndicator];
    [self refreshTipUI];
}

#pragma mark
#pragma mark-- setter方法
- (void)setTinColor:(UIColor *)tinColor {
    _tinColor = tinColor;
    self.backgroundColor = tinColor;
}


@end
