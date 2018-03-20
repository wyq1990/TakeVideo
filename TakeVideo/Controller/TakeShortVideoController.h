//
//  TakeShortVideoController.h
//  TakeVideo
//
//  Created by heyk on 18/4/2016.
//  Copyright © 2016 成都好房通股份科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TakeVideo.h"

@protocol TakeShortVideoControllerDelegate <NSObject>

- (void)didFinishMergingVideosToOutPut:(UIViewController*)controller fileAtURL:(NSURL*)videoPath videoSize:(CGSize)videoSize ;


@end

@interface TakeShortVideoController : UIViewController

@property (nonatomic, assign) BOOL enableFlash;// 是否显示闪光按钮
@property (nonatomic, assign) BOOL enableChangeCamraPositon;// 是否可以修改相机方向
@property (nonatomic, assign) BOOL enableLandscaping;// 是否开启美化功能
@property (nonatomic, strong) UIImage *waterImage;// 水印图片
@property (nonatomic, assign) WatermarkPosition waterPosition;//水印位置
@property (nonatomic, assign) CameraPosition cameraPosition;//  默认摄像头位置
@property (nonatomic, assign) CGSize videoSize;//  视频尺寸
@property (nonatomic, strong) UIColor *progressColor;// 进度条颜色

@property (nonatomic, assign) id<TakeShortVideoControllerDelegate> delegate;

/**
 *  初始化
 *
 *  @param minDuration 最短录制时间
 *  @param maxDuration 最长录制时间
 *
 *  @return 
 */
- (instancetype)initWithMinDuration:(CGFloat)minDuration
                        maxDuration:(CGFloat)maxDuration;

@end
