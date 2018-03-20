//
//  BottomView.h
//  TakeVideo
//
//  Created by heyk on 20/4/16.
//  Copyright © 2016年 成都好房通股份科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    DeleteButtonStyleDelete,
    DeleteButtonStyleNormal,
    DeleteButtonStyleDisable,
}DeleteButtonStyle;

@protocol BottomViewDelegate <NSObject>
/**
 *  开始录制按钮
 *
 *  @param filePath 文件将要存储的位置
 */
- (void)starRecordWithFilePath:(NSString*)filePath;

/**
 *  结束录制按钮按压
 */
- (void)stopCurrentVideoRecording;

/**
 *  准备删除最后一段视频
 */
- (void)willDeleteLastVideo;

/**
 *  已经删除最后一段视频
 */
- (void)didDeleteLastVideo;

/**
 *  合成视频
 */
- (void)mergeVideo;

@end

@interface BottomView : UIView

@property (nonatomic, weak)id<BottomViewDelegate> delegate;

@property (nonatomic, assign) DeleteButtonStyle deleteStyle;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIButton *doneButton;



@end
