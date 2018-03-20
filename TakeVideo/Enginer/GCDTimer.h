//
//  GCDTimer.h
//  Erp4iOS
//
//  Created by 开发者 on 16/4/15.
//  Copyright © 2016年 成都好房通科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    AbandonPreviousAction, // 废除之前的任务
    MergePreviousAction    // 将之前的任务合并到新的任务中
} ActionOption;


@interface GCDTimer : NSObject

/**
 *  创建单例
 *
 *  @return GCDTimer 单例
 */
+ (GCDTimer *)sharedInstance;

/**
 *  开启一个CGD Timer
 *
 *  @param timerName 计时器的标识
 *  @param interval  间隔时间
 *  @param queue     队列
 *  @param repeats   是否重复
 *  @param option    是否废除之前任务
 *  @param action    执行方法
 */
- (void)scheduledDispatchTimerWithName:(NSString *)timerName
                          timeInterval:(double)interval
                                 queue:(dispatch_queue_t)queue
                               repeats:(BOOL)repeats
                          actionOption:(ActionOption)option
                                action:(dispatch_block_t)action;

/**
 *  取消指定Timer
 *
 *  @param timerName 每个计时器的标识
 */
- (void)cancelTimerWithName:(NSString *)timerName;

/**
 *  取消所有计时器
 */
- (void)cancelAllTimer;

@end
