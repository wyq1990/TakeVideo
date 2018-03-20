//
//  TakeVideoNavBar.h
//  TakeVideo
//
//  Created by heyk on 19/4/2016.
//  Copyright © 2016 成都好房通股份科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TakeVideo.h"

@protocol TakeVideoNavBarDelegate <NSObject>

@optional

/**
 *  关闭当前窗口
 */
- (void)closeWindow;

/**
 *  关闭闪光灯
 */
- (void)closeFlash;

/**
 *  开启闪光灯
 */
- (void)openFlash;

/**
 *  关闭美颜效果
 */
- (void)closeLandscaping;

/**
 *  开启美颜效果
 */
- (void)openLandscaping;

/**
 *  打开前置摄像头
 */
- (void)openFrontCamera;

/**
 *  打开后置摄像头
 */
- (void)openBackCamera;


@end

@interface TakeVideoNavBar : UIView

@property (nonatomic, assign) BOOL enableFlash;// 是否显示闪光按钮
@property (nonatomic, assign) BOOL enableChangeCamraPositon;// 是否可以修改相机方向
@property (nonatomic, assign) BOOL enableLandscaping;// 是否开启美化功能
@property (nonatomic, assign) CameraPosition defaultCameraPostion;// 默认摄像头方向，不设置为后置摄像头

@property (nonatomic, weak) id<TakeVideoNavBarDelegate> delegate;

/**
 *   初始化
 *
 *  @param frame
 *  @param delegate
 *
 *  @return 
 */
- (instancetype)initWithFrame:(CGRect)frame
       withDelegate:(id<TakeVideoNavBarDelegate>)delegate;

@end
