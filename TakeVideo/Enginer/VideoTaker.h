//
//  VideoTaker.h
//  TakeVideo
//
//  Created by heyk on 20/4/16.
//  Copyright © 2016年 成都好房通股份科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "TakeVideo.h"

@class VideoTaker;
@protocol VideoTakerDelegate <NSObject>

@optional
/**
 *  开始录制视频
 *
 *  @param videoRecorder
 *  @param fileURL       视频将要存储的路径
 */
- (void)videoRecorder:(VideoTaker *)videoRecorder
    didStartRecordingToOutPutFileAtURL:(NSURL *)fileURL;

/**
 *  录制完一段视频
 *
 *  @param videoRecorder
 *  @param outputFileURL 视频存储路径
 *  @param videoDuration 此段视频长度
 *  @param totalDur      目前已录制的视频总长度
 *  @param error
 */
- (void)videoRecorder:(VideoTaker *)videoRecorder
    didFinishRecordingToOutPutFileAtURL:(NSURL *)outputFileURL
        duration:(CGFloat)videoDuration
             totalDur:(CGFloat)totalDur
                error:(NSError *)error;

/**
 *  正在录制视频
 *
 *  @param videoRecorder
 *  @param outputFileURL 正在录制的视频存储路径
 *  @param videoDuration 正在录制的视频长度
 *  @param totalDur      已录制的视频长度
 */
- (void)videoRecorder:(VideoTaker *)videoRecorder
    didRecordingToOutPutFileAtURL:(NSURL *)outputFileURL
        duration:(CGFloat)videoDuration
            recordedVideosTotalDur:(CGFloat)totalDur;

/**
 *  删除某一段视频
 *
 *  @param videoRecorder
 *  @param fileURL       删除的视频存储路径
 *  @param totalDur      剩下的视频总时长
 *  @param error
 */
- (void)videoRecorder:(VideoTaker *)videoRecorder
    didRemoveVideoFileAtURL:(NSURL *)fileURL
        totalDur:(CGFloat)totalDur
            error:(NSError *)error;

/**
 *  合成一段视频晚餐
 *
 *  @param videoRecorder
 *  @param outputFileURL 合成后的视频存储路径
 */
- (void)videoRecorder:(VideoTaker *)videoRecorder
    didFinishMergingVideosToOutPutFileAtURL:(NSURL *)outputFileURL ;

@end


@interface VideoTaker :  NSObject <AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, weak) id <VideoTakerDelegate> delegate;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preViewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic, assign) CGFloat maxDuration;// 视频最大录制时间
@property (nonatomic, assign) CameraPosition cameraPostion;// 默认摄像头方向，不设置为后置摄像头
@property (nonatomic, assign) BOOL bOpenFlash;// 是否开启闪光灯
@property (nonatomic, assign) CGSize videoSize;// 视频size
@property (nonatomic, strong) UIImage *waterImage;//水印图片
@property (nonatomic, assign) WatermarkPosition waterPosition;//水印位置


/**
 *  开始录制视频并存入本地
 *
 *  @param filePath 本地路径
 */
- (void)startRecordingToOutputFilePath:(NSString *)filePath;

/**
 *  停止录制当前视频录制
 */
- (void)stopCurrentVideoRecording;

/**
 *  获取当前所录制的视频总时长
 *
 *  @return
 */
- (CGFloat)getTotalVideoDuration;

/**
 *  调用delegate
 */
- (void)deleteLastVideo;

/**
 *  不调用delegate
 */
- (void)deleteAllVideo;

/**
 *  获取当前视频个数
 *
 *  @return
 */
- (NSUInteger)getVideoCount;

/**
 *  合并视频
 */
- (void)mergeVideoFiles;

/**
 *  是否支持打开摄像头
 *
 *  @return
 */
- (BOOL)isCameraSupported;

/**
 *  是否支持闪光灯
 *
 *  @return
 */
- (BOOL)isTorchSupported;

/**
 *  开启闪光灯
 *
 *  @param open ，yes 开启，no 关闭
 */
- (void)openTorch:(BOOL)open;

/**
 *  对焦到某个点
 *
 *  @param touchPoint
 */
- (void)focusInPoint:(CGPoint)touchPoint;

/**
 *  change video 焦距
 *
 *  @param fScale 缩放比例
 */
- (void)changeVideoScale:(float)fScale;

/**
 *  当前视频缩放比例
 *
 *  @return
 */
- (CGFloat)currentVideoScale;

@end