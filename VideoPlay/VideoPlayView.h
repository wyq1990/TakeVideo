//
//  VideoPlayView.h
//  Erp4iOS
//
//  Created by 开发者 on 16/4/12.
//  Copyright © 2016年 成都好房通科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoPlayView;

@protocol VideoPlayViewDelegate <NSObject>

@optional
- (void)playDidEnd:(VideoPlayView*)view;

@end


@interface VideoPlayView : UIView
@property (nonatomic, assign) BOOL bHiddenCloseButton ;
@property (nonatomic, weak) id<VideoPlayViewDelegate> delegate;

/**
 * 初始化
 * url : 视频播放地址
 *
 */
- (id)initWithVideoURL:(NSString*)url;

/**
 *  初始化
 *
 *  @param path 视频播放本地路径
 *
 *  @return
 */
- (id)initWithVideoContentPath:(NSURL*)path;
/**
 * 在指定view上展示
 */
- (void)showOnView:(UIView*)view;

/**
 * 在指定view上展示
 */
- (void)showOnView:(UIView*)view frame:(CGRect)frame;

/**
 * 在window上展示
 * frame 小窗口时的size
 */
- (void)showOnWindowWithMinSize:(CGSize)size;

/**
 * 移除
 */
- (void)dismiss;

@end
