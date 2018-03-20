//
//  VideoTaker.m
//  TakeVideo
//
//  Created by heyk on 20/4/16.
//  Copyright © 2016年 成都好房通股份科技有限公司. All rights reserved.
//

#import "VideoTaker.h"
#import "TakeVideoModel.h"
#import "VideoFileEnginer.h"
#import "GCDTimer.h"

#define COUNT_DUR_TIMER_INTERVAL 0.05

@interface VideoTaker()


@property (nonatomic, assign) CGFloat currentVideoDur;
@property (nonatomic, assign) CGFloat totalVideoDur;
@property (nonatomic,   copy) NSString *recordTimer;
@property (nonatomic, strong) NSMutableArray *videoFileDataArray;
@property (nonatomic, strong) NSURL *currentFileURL;

@property (nonatomic, assign) BOOL isFrontCameraSupported;
@property (nonatomic, assign) BOOL isCameraSupported;
@property (nonatomic, assign) BOOL isTorchSupported;

@property (nonatomic, strong) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic, strong) AVCaptureDevice *currentDevice;

@end



@implementation VideoTaker

- (void)dealloc {
    [self stopCountDurTimer];
}

- (id)init {
    self = [super init];
    if (self) {
        [self initalize];
    }
    return self;
}

- (void)initalize {
    [self initCapture];
    self.videoSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.videoFileDataArray = [[NSMutableArray alloc] init];
    self.totalVideoDur = 0.0f;
}

- (void)initCapture {
    //session---------------------------------
    self.captureSession = [[AVCaptureSession alloc] init];
    
    //input
    AVCaptureDevice *frontCamera = nil;
    AVCaptureDevice *backCamera = nil;
    
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if (camera.position == AVCaptureDevicePositionFront) {
            frontCamera = camera;
        } else {
            backCamera = camera;
        }
    }
    
    if (!backCamera) {
        self.isCameraSupported = NO;
        return;
    } else {
        self.isCameraSupported = YES;
        
        if ([backCamera hasTorch]) {
            self.isTorchSupported = YES;
        } else {
            self.isTorchSupported = NO;
        }
    }
    
    if (!frontCamera) {
        self.isFrontCameraSupported = NO;
    } else {
        self.isFrontCameraSupported = YES;
    }
    
    [backCamera lockForConfiguration:nil];
    if ([backCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [backCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    
    [backCamera unlockForConfiguration];
    _currentDevice = backCamera;
    
    self.videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:nil];
    AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:nil];
    if ([_captureSession canAddInput:_videoDeviceInput]) {
        [_captureSession addInput:_videoDeviceInput];
    }
    if ([_captureSession canAddInput:audioDeviceInput]) {
        [_captureSession addInput:audioDeviceInput];
    }
    //output
    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([_captureSession canAddOutput:_movieFileOutput]) {
        [_captureSession addOutput:_movieFileOutput];
    }

    
    //preset
    _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    //preview layer------------------
    self.preViewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    _preViewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [_captureSession startRunning];
}

- (void)startCountDurTimer {
    self.recordTimer = @"recordTimer";
    __weak typeof(self) weakSelf = self;
    [[GCDTimer sharedInstance] scheduledDispatchTimerWithName:_recordTimer
                                                 timeInterval:COUNT_DUR_TIMER_INTERVAL
                                                        queue:nil
                                                      repeats:YES
                                                 actionOption:AbandonPreviousAction
                                                       action:^{
                                                           [weakSelf onTimer];
                                                       }];
}

- (void)onTimer {
    self.currentVideoDur += COUNT_DUR_TIMER_INTERVAL;
    
    if ([_delegate respondsToSelector:@selector(videoRecorder:didRecordingToOutPutFileAtURL:duration:recordedVideosTotalDur:)]) {
        [_delegate videoRecorder:self didRecordingToOutPutFileAtURL:_currentFileURL duration:_currentVideoDur recordedVideosTotalDur:_totalVideoDur];
    }
    
    if (_totalVideoDur + _currentVideoDur >= _maxDuration) {
        [self stopCurrentVideoRecording];
    }
}

- (void)stopCountDurTimer {
    if (_recordTimer) {
        [[GCDTimer sharedInstance] cancelTimerWithName:_recordTimer];
        self.recordTimer = nil;
    }
}

//必须是fileURL

- (void)mergeAndExportVideosAtFileURLs:(NSArray *)videlDataArray {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        
        CGSize renderSize = CGSizeMake(0, 0);
        
        // 存放AVMutableVideoCompositionLayerInstruction 对象
        NSMutableArray *layerInstructionArray = [[NSMutableArray alloc] init];
        
        // 取出assetTrack 和 renderSize
        NSMutableArray *assetTrackArray = [[NSMutableArray alloc] init];
        NSMutableArray *assetArray = [[NSMutableArray alloc] init];
        for (TakeVideoModel *data in videlDataArray) {
            AVAsset *asset = [AVAsset assetWithURL:data.fileURL];
            
            if (!asset) {
                continue;
            }
            [assetArray addObject:asset];
            
            AVAssetTrack *assetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            [assetTrackArray addObject:assetTrack];
            
            renderSize.width = assetTrack.naturalSize.height;
            renderSize.height = assetTrack.naturalSize.width;
        }
        
        CGSize realSize = CGSizeMake(renderSize.width, renderSize.width * _videoSize.height/_videoSize.width);
        
//        AVAsset：素材库里的素材；
//        AVAssetTrack：素材的轨道；
//        AVMutableComposition ：一个用来合成视频的工程文件；
//        AVMutableCompositionTrack ：工程文件中的轨道，有音频轨、视频轨等，里面可以插入各种对应的素材；
//        AVMutableVideoCompositionLayerInstruction：视频轨道中的一个视频，可以缩放、旋转等；
//        AVMutableVideoCompositionInstruction：一个视频轨道，包含了这个轨道上的所有视频素材；
//        AVMutableVideoComposition：管理所有视频轨道，可以决定最终视频的尺寸，裁剪需要在这里进行；
//        AVAssetExportSession：配置渲染参数并渲染。
        
        
        // 1.生成视频合成工具
        AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
        CMTime totalDuration = kCMTimeZero;
        
        //视频轨迹
        AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        //音频轨迹
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        // 2.将每段视频的AVMutableCompositionTrack 取出，添加到AVMutableComposition对象
        for (int i = 0; i < [assetArray count] && i < [assetTrackArray count]; i++) {
            
            AVAsset *asset = [assetArray objectAtIndex:i];
            AVAssetTrack *assetTrack = [assetTrackArray objectAtIndex:i];
//            TakeVideoModel *data  = [videlDataArray objectAtIndex:i];
//
            //插入音轨
           [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                 atTime:totalDuration
                                  error:nil];
            
            //插入视轨
            [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                ofTrack:assetTrack
                                 atTime:totalDuration
                                  error:&error];
            
            //fix orientationissue
            AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
            
            totalDuration = CMTimeAdd(totalDuration, asset.duration);
            
         
            CGAffineTransform layerTransform = assetTrack.preferredTransform;
            
            CGFloat realHeight = renderSize.width * _videoSize.height /_videoSize.width ;
            
            CGFloat fMoveY =  (renderSize.height - realHeight)/2;
            layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0,-fMoveY));
            layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMakeScale(_videoSize.width/realSize.width, _videoSize.width/realSize.width));
            

            [layerInstruciton setTransform:layerTransform atTime:kCMTimeZero];
            [layerInstruciton setOpacity:0.0 atTime:totalDuration];
            
            
            //data
            [layerInstructionArray addObject:layerInstruciton];
        }
        
        //get save path
        NSURL *mergeFileURL = [NSURL fileURLWithPath:[VideoFileEnginer getVideoMergeFilePathString]];
        
        //export
        AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
        mainInstruciton.layerInstructions = layerInstructionArray;
        
        
        AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
        mainCompositionInst.instructions = @[mainInstruciton];
        mainCompositionInst.frameDuration = CMTimeMake(1, 30);
        mainCompositionInst.renderSize = _videoSize;
        if(_waterImage){//加水印
            
            [self applyVideoEffectsToComposition:mainCompositionInst overlayImage:_waterImage position:_waterPosition naturalSize: mainCompositionInst.renderSize];
        }
        
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
        exporter.videoComposition = mainCompositionInst;
        exporter.outputURL = mergeFileURL;
        exporter.outputFileType = AVFileTypeMPEG4;
        exporter.shouldOptimizeForNetworkUse = YES;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(videoRecorder:didFinishMergingVideosToOutPutFileAtURL:)]) {
                    [_delegate videoRecorder:self didFinishMergingVideosToOutPutFileAtURL:mergeFileURL];
                }
            });
        }];
    });
    
    
}

// 加水印
- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition
                          overlayImage:(UIImage *)overlayImage
                              position:(WatermarkPosition)position
                           naturalSize:(CGSize)size
{
    // 1－创建水印图层
    CALayer *imageLayer = [CALayer layer];
    [imageLayer setContents:(id)[overlayImage CGImage]];
    imageLayer.frame = CGRectMake(0, 0, overlayImage.size.width, overlayImage.size.height);
    
    if (position == WatermarkPositionTopRight) {
        imageLayer.frame = CGRectMake(size.width -  overlayImage.size.width,  size.height - overlayImage.size.height , overlayImage.size.width, overlayImage.size.height);
    }
    else if(position == WatermarkPositionBottomRight){
          imageLayer.frame = CGRectMake(size.width -  overlayImage.size.width, 0, overlayImage.size.width, overlayImage.size.height);
    }
    else if(position == WatermarkPositionTopLeft){
        imageLayer.frame = CGRectMake(0, size.height - overlayImage.size.height, overlayImage.size.width, overlayImage.size.height);
    }
    // 2-创建承载水印的图层
    CALayer *overlayLayer = [CALayer layer];
    [overlayLayer addSublayer:imageLayer];
    overlayLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [overlayLayer setMasksToBounds:YES];
    
    // 3-创建parentLayer
    CALayer *parentLayer = [CALayer layer];
    
    // 4-创建视频展示图层
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    
    // 5-保证水印在视频图层之上
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];
    
    // 6-合成
    composition.animationTool = [AVVideoCompositionCoreAnimationTool
                                 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}


- (AVCaptureDevice *)getCameraDevice:(BOOL)isFront {
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *camera in cameras) {
        if (camera.position == AVCaptureDevicePositionBack) {
            backCamera = camera;
        } else {
            frontCamera = camera;
        }
    }
    
    if (isFront) {
        return frontCamera;
    }
    
    return backCamera;
}

- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates {
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = _preViewLayer.bounds.size;
    
    AVCaptureVideoPreviewLayer *videoPreviewLayer = self.preViewLayer;//需要按照项目实际情况修改
    
    if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResize]) {
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        
        for(AVCaptureInputPort *port in [self.videoDeviceInput ports]) {
            if([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResizeAspect]) {
                    if(viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
                        if(point.x >= blackBar && point.x <= blackBar + x2) {
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
                        if(point.y >= blackBar && point.y <= blackBar + y2) {
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                    if(viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2;
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
                        xc = point.y / frameSize.height;
                    }
                    
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange {
    //    NSLog(@"focus point: %f %f", point.x, point.y);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVCaptureDevice *device = [_videoDeviceInput device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            if ([device isFocusPointOfInterestSupported]) {
                [device setFocusPointOfInterest:point];
            }
            
            if ([device isFocusModeSupported:focusMode]) {
                [device setFocusMode:focusMode];
            }
            
            if ([device isExposurePointOfInterestSupported]) {
                [device setExposurePointOfInterest:point];
            }
            
            if ([device isExposureModeSupported:exposureMode]) {
                [device setExposureMode:exposureMode];
            }
            
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        } else {
            NSLog(@"对焦错误:%@", error);
        }
    });
}


#pragma mark - Method
- (void)focusInPoint:(CGPoint)touchPoint {
    CGPoint devicePoint = [self convertToPointOfInterestFromViewCoordinates:touchPoint];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}



- (void)openTorch:(BOOL)open {
    if (!_isTorchSupported) {
        return;
    }
    
    AVCaptureTorchMode torchMode;
    if (open) {
        torchMode = AVCaptureTorchModeOn;
    } else {
        torchMode = AVCaptureTorchModeOff;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [device lockForConfiguration:nil];
        [device setTorchMode:torchMode];
        [device unlockForConfiguration];
    });
}

- (void)switchCamera:(CameraPosition)postion {
    if (!_isCameraSupported || !_videoDeviceInput) {
        return;
    }
    
    if (_bOpenFlash) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kCAMERAFLASHAUTOCHANGED object:[NSNumber numberWithBool:NO]];
        [self openTorch:NO];
    }
    
    [_captureSession beginConfiguration];
    [_captureSession removeInput:_videoDeviceInput];
    
    
    BOOL bFront = NO;
    if (postion == CameraPositionFront) {
        bFront = YES;
    }
    _currentDevice = [self getCameraDevice:bFront];

    [_currentDevice lockForConfiguration:nil];
    if ([_currentDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [_currentDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    [_currentDevice unlockForConfiguration];
    
    self.videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_currentDevice error:nil];
    [_captureSession addInput:_videoDeviceInput];
    [_captureSession commitConfiguration];
}

- (BOOL)isTorchSupported {
    return _isTorchSupported;
}

- (BOOL)isFrontCameraSupported {
    return _isFrontCameraSupported;
}

- (BOOL)isCameraSupported {
    return _isFrontCameraSupported;
}

- (void)mergeVideoFiles {

    [self mergeAndExportVideosAtFileURLs:_videoFileDataArray];
}

//总时长
- (CGFloat)getTotalVideoDuration {
    return _totalVideoDur;
}

//现在录了多少视频
- (NSUInteger)getVideoCount {
    return [_videoFileDataArray count];
}

- (void)startRecordingToOutputFilePath:(NSString *)filePath {
    if (_totalVideoDur >= _maxDuration) {
        NSLog(@"视频总长达到最大");
        return;
    }
    
    [_movieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:filePath] recordingDelegate:self];
}

- (void)stopCurrentVideoRecording {
    [self stopCountDurTimer];
    [_movieFileOutput stopRecording];
}

//不调用delegate
- (void)deleteAllVideo {
    for (TakeVideoModel *data in _videoFileDataArray) {
        NSURL *videoFileURL = data.fileURL;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *filePath = [[videoFileURL absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:filePath]) {
                NSError *error = nil;
                [fileManager removeItemAtPath:filePath error:&error];
                
                if (error) {
                    NSLog(@"deleteAllVideo删除视频文件出错:%@", error);
                }
            }
        });
    }
}

//会调用delegate
- (void)deleteLastVideo {
    if ([_videoFileDataArray count] == 0) {
        return;
    }
    
    TakeVideoModel *data = (TakeVideoModel *)[_videoFileDataArray lastObject];
    
    NSURL *videoFileURL = data.fileURL;
    CGFloat videoDuration = data.duration;
    
    [_videoFileDataArray removeLastObject];
    _totalVideoDur -= videoDuration;
    
    //delete
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *filePath = [[videoFileURL absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:filePath]) {
            NSError *error = nil;
            [fileManager removeItemAtPath:filePath error:&error];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //delegate
                if ([_delegate respondsToSelector:@selector(videoRecorder:didRemoveVideoFileAtURL:totalDur:error:)]) {
                    [_delegate videoRecorder:self didRemoveVideoFileAtURL:videoFileURL totalDur:_totalVideoDur error:error];
                }
            });
        }
    });
}

- (void)changeVideoScale:(float)fScale {
    
    if ([_currentDevice lockForConfiguration:nil]) {
        [_currentDevice setVideoZoomFactor:fScale];
        [_currentDevice unlockForConfiguration];
    }
}
- (CGFloat)currentVideoScale {
    if (_currentDevice) {
        return _currentDevice.videoZoomFactor;
    }
    return 1;
}
#pragma mark - AVCaptureFileOutputRecordignDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
    self.currentFileURL = fileURL;
    
    self.currentVideoDur = 0.0f;
    [self startCountDurTimer];
    
    if ([_delegate respondsToSelector:@selector(videoRecorder:didStartRecordingToOutPutFileAtURL:)]) {
        [_delegate videoRecorder:self didStartRecordingToOutPutFileAtURL:fileURL];
    }
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    self.totalVideoDur += _currentVideoDur;
    NSLog(@"本段视频长度: %f", _currentVideoDur);
    NSLog(@"现在的视频总长度: %f", _totalVideoDur);
    
    if (!error) {
        TakeVideoModel *data = [[TakeVideoModel alloc] init];
        data.duration = _currentVideoDur;
        data.fileURL = outputFileURL;
        [_videoFileDataArray addObject:data];
    }
    
    if ([_delegate respondsToSelector:@selector(videoRecorder:didFinishRecordingToOutPutFileAtURL:duration:totalDur:error:)]) {
        [_delegate videoRecorder:self didFinishRecordingToOutPutFileAtURL:outputFileURL duration:_currentVideoDur totalDur:_totalVideoDur error:error];
    }
}


#pragma mark
#pragma mark-- setter 方法
- (void)setBOpenFlash:(BOOL)bOpenFlash {

    _bOpenFlash = bOpenFlash;
    [self openTorch:_bOpenFlash];
}

- (void)setCameraPostion:(CameraPosition)cameraPostion {
    _cameraPostion = cameraPostion;
    [self switchCamera:cameraPostion];
}

@end
