//
//  VideoFileEnginer.h
//  TakeVideo
//
//  Created by heyk on 20/4/16.
//  Copyright © 2016年 成都好房通股份科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoFileEnginer : NSObject

/**
 * 生成合并后的视频路径
 *
 *  @return 视频路径
 */
+ (NSString *)getVideoMergeFilePathString;


/**
 *  生成录制过程中的视频路径
 *
 *  @return 录制小段的视频路径
 */
+ (NSString *)getVideoSaveFilePathString;

@end
