//
//  TakeVideoProgressView.h
//  TakeVideo
//
//  Created by heyk on 20/4/16.
//  Copyright © 2016年 成都好房通股份科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ProgressBarProgressStyleNormal,
    ProgressBarProgressStyleDelete,
} ProgressBarProgressStyle;

@interface TakeVideoProgressView : UIView

@property (nonatomic, strong) UIColor *tinColor; //底部背景颜色
@property (nonatomic, strong) UIColor *trackColor; //进度颜色
@property (nonatomic, strong) UIColor *sperateLineColor;// 每段分割线颜色
@property (nonatomic, strong) UIColor *minTimeLineColor;// 最小录制时间分割线颜色
@property (nonatomic, strong) UIColor *timeTipColor;// 时间显示标签背景色
@property (nonatomic, strong) UIColor *willDeleteColor;// 将要删除的视频分段颜色
@property (nonatomic, assign) CGFloat totalDuration;// 视频总时间


- (id)initWithframe:(CGRect)frame
        minDuration:(CGFloat)minDuration
        maxDuration:(CGFloat)maxDuration ;

/**
 *  设置最长和最短录制时间
 *
 *  @param minDuration 最短录制时间，至少大于1s
 *  @param maxDuration 最长录制时间
 */
- (void)setMinDuration:(CGFloat)minDuration
           maxDuration:(CGFloat)maxDuration;

/**
 *  修改最后一个进度的状态
 *
 *  @param style
 */
- (void)setLastProgressToStyle:(ProgressBarProgressStyle)style;

/**
 *  增加一段新进度
 */
- (void)addProgressView;

/**
  *  设置进度条长度
  *
  *  @param width 
  *  @param lastTime 最后一段视频长的
  *  @param totalTime 所有已经录制了的视频长度
  */
- (void)setLastProgressToWidth:(CGFloat)width
                      lastTime:(CGFloat)lastTime
                     totleTime:(CGFloat)totalTime;

/**
 *  移除最后一段
 */
- (void)removeLastProgressView;

/**
 *  开始指示图标动画
 */
- (void)starIndicatorAniamtion;

/**
 *  停止指示图标动画
 */
- (void)stopIndicatorAnimation;

/**
 *  隐藏指示图标
 */
- (void)hiddenIndicator;

/**
 *  显示指示图标
 */
- (void)showIndicator;

@end
