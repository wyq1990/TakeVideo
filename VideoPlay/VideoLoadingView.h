//
//  VideoLoadingView.h
//  Erp4iOS
//
//  Created by 开发者 on 16/4/15.
//  Copyright © 2016年 成都好房通科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoLoadingView : UIView

@property (nonatomic, assign) BOOL bAnimation; // 是否正在执行动画
/**
 *  开始加载动画
 */
- (void)startAnimation;

/**
 *  结束加载动画
 */
- (void)stopAnimation;

@end
