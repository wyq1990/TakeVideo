//
//  VideoPlayToolBar.h
//  Erp4iOS
//
//  Created by 开发者 on 16/4/12.
//  Copyright © 2016年 成都好房通科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol VideoPlayToolBarDelegate <NSObject>

/**
 * 点击播放按钮响应协议
 */
- (void)startPlay;

/**
 * 点击暂停按钮响应协议
 */
- (void)pause;

/**
 * 拖动进度条响应协议
 */
- (void)changeProgress:(float)progress;

/**
 * 点击全屏响应协议
 */
- (void)showFullScreen;

/**
 * 点击退出全屏响应协议
 */
- (void)hiddenFullScreen;

/**
 * 修改slider进度结束
 */
- (void)didEndChangeProgress;

@end



@interface VideoPlayToolBar : UIView

@property (nonatomic, weak) id<VideoPlayToolBarDelegate> delegate;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, assign) float currentProgress;
@property (nonatomic, assign) BOOL  isPlaying;


/**
 * 主动开始播放
 */
- (void)play;

/**
 * 设置显示视频总时长
 */
- (void)setTotleTime:(float)time;

/**
 * 设置当前视频播放时间
 */
- (void)setplayedTime:(float)time;

/**
 * 播放完成，改变按钮状态等
 */
- (void)pause;



/**
 * 动画隐藏或者显示
 */
- (void)showOrHidden;


/**
 * 设置缓冲进度
 */
- (void)setCacheProgress:(float)progress;

/**
 * 停止计数器
 */
- (void)stopTimer;

/**
 *  全屏模式
 */
- (void)showFullStatus;

/**
 *  小屏模式
 */
- (void)showMinStatus;

@end
