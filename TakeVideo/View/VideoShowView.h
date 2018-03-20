//
//  VideoShowView.h
//  TakeVideo
//
//  Created by heyk on 20/4/16.
//  Copyright © 2016年 成都好房通股份科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TakeVideo.h"
#import "VideoTaker.h"


@interface VideoShowView : UIView

@property (nonatomic, assign) CameraPosition cameraPostion;// 默认摄像头方向，不设置为后置摄像头
@property (nonatomic, assign) BOOL bOpenFlash;// 是否开启闪光灯
@property (nonatomic, strong) VideoTaker *taker;
@property (nonatomic, assign) CGFloat maxDuraTime;
@property (nonatomic, strong) UIImage *waterImage;//水印图片
@property (nonatomic, assign) WatermarkPosition waterPosition;//水印位置
@property (nonatomic, assign) CGSize videoSize;//  视频尺寸


/**
 *  初始化
 *
 *  @param frame   view frame
 *  @param maxTime 最大录制时间
 *
 *  @return
 */
- (id)initWithFrame:(CGRect)frame maxDuraTime:(CGFloat)maxTime;

/**
 *  设置VideoTaker delegate
 *
 *  @param delegate
 */
- (void)setDelegate:(id)delegate;


@end
