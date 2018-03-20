//
//  RecordTimeTipView.h
//  TakeVideo
//
//  Created by heyk on 21/4/16.
//  Copyright © 2016年 成都好房通股份科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordTimeTipView : UIView

/**
 *  设置时间
 *
 *  @param seconds 秒
 */
- (void)setCurrentSeconds:(float)seconds;

/**
 *  显示尖尖在左边的图片
 */
- (void)showLeftTip;

/**
 *  显示尖尖在右边的图片
 */
- (void)showRightTip;

@end
