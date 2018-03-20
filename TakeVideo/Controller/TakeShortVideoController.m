//
//  TakeShortVideoController.m
//  TakeVideo
//
//  Created by heyk on 18/4/2016.
//  Copyright © 2016 成都好房通股份科技有限公司. All rights reserved.
//

#import "TakeShortVideoController.h"
#import "TakeVideoNavBar.h"
#import "BottomView.h"
#import "VideoShowView.h"
#import "TakeVideoProgressView.h"
#import <AssetsLibrary/AssetsLibrary.h>


#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight  [UIScreen mainScreen].bounds.size.height


@interface TakeShortVideoController ()<TakeVideoNavBarDelegate,BottomViewDelegate>{
    
    TakeVideoNavBar *topBar;
    TakeVideoProgressView *progressView;
    VideoShowView *videoShowView;
    BottomView *bottomView;
    UIActivityIndicatorView *activity;
}

@property (nonatomic, assign) CGFloat minDuration; // 最短录制时间
@property (nonatomic, assign) CGFloat maxDuration; // 最长录制时间

@end

@implementation TakeShortVideoController

- (void)dealloc {
    NSLog(@"TakeShortVideoController======");
}

- (instancetype)initWithMinDuration:(CGFloat)minDuration
                        maxDuration:(CGFloat)maxDuration {
    
    self = [super init];
    if (self) {
        self.minDuration = minDuration;
        self.maxDuration = maxDuration;
        [self initialization];
    }
    return self;
}

- (void)initialization {
    
    // add and init top tool bar view
    topBar  = [[TakeVideoNavBar alloc] initWithFrame:CGRectMake(0, 0,kScreenWidth, 44)
                                        withDelegate:self];
    [self.view addSubview:topBar];
    topBar.enableLandscaping = NO;
    
    // add progress View
    progressView = [[TakeVideoProgressView alloc] initWithframe:CGRectMake(0,
                                                                           topBar.frame.origin.y + topBar.frame.size.height,
                                                                           kScreenWidth,
                                                                           3)
                                                    minDuration:_minDuration
                                                    maxDuration:_maxDuration];
    
    [self.view addSubview:progressView];
    
    // video player view
    videoShowView = [[VideoShowView alloc] initWithFrame:CGRectMake(0,
                                                                    progressView.frame.origin.y + progressView.frame.size.height,
                                                                    kScreenWidth,
                                                                    300)
                                             maxDuraTime:_maxDuration];
    
    _videoSize = CGSizeMake(kScreenWidth, 300);
    [videoShowView setDelegate:self];
    [self.view insertSubview:videoShowView belowSubview:progressView];

    //add bottom view
    bottomView = [[BottomView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 200, kScreenWidth, 200)];
    bottomView.delegate = self;
    [self.view addSubview:bottomView];
    
    activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activity.hidesWhenStopped = YES;
    activity.center = videoShowView.center;
    [videoShowView addSubview:activity];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
        self.navigationController.navigationBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark
#pragma mark-- 私有方法
// 修改底部view各个按钮显示
- (void)setBottomStatusWithTotalDuration:(CGFloat)duration {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (duration <= 0) {
            bottomView.deleteButton.hidden = YES;
            bottomView.doneButton.hidden = YES;
        }
        else{
            bottomView.deleteButton.hidden = NO;
            bottomView.doneButton.hidden = NO;
            if (duration >= _minDuration) {
                bottomView.doneButton.enabled = YES;
            }
            else{
                bottomView.doneButton.enabled = NO;
            }
        }
    });
}

#pragma mark
#pragma mark-- setter 方法
- (void)setEnableFlash:(BOOL)enableFlash {
    _enableFlash = enableFlash;
    topBar.enableFlash = enableFlash;
}

- (void)setEnableLandscaping:(BOOL)enableLandscaping {
    _enableLandscaping = enableLandscaping;
    topBar.enableLandscaping = enableLandscaping;
}

- (void)setEnableChangeCamraPositon:(BOOL)enableChangeCamraPositon {
    _enableChangeCamraPositon = enableChangeCamraPositon;
    topBar.enableChangeCamraPositon = enableChangeCamraPositon;
}


- (void)setWaterPosition:(WatermarkPosition)waterPosition {
    _waterPosition = waterPosition;
    if (videoShowView) {
        videoShowView.waterPosition = _waterPosition;
    }
}

- (void)setCameraPosition:(CameraPosition)cameraPosition {
    _cameraPosition = cameraPosition;
    if (videoShowView) {
        videoShowView.cameraPostion = cameraPosition;
    }
    
}
- (void)setProgressColor:(UIColor *)progressColor {
    if (progressView) {
        progressView.tinColor = progressColor;
    }
}
- (void)setWaterImage:(UIImage *)waterImage {
    _waterImage = waterImage;
    if (videoShowView) {
        videoShowView.waterImage = _waterImage;
    }
}
- (void)setVideoSize:(CGSize)videoSize {
    if (videoShowView) {
        videoShowView.videoSize = videoSize;
    }
}

#pragma mark - TakeVideoNavBarDelegate

- (void)closeWindow {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)closeFlash {
    videoShowView.bOpenFlash = NO;
}


- (void)openFlash {
    videoShowView.bOpenFlash = YES;
}


- (void)closeLandscaping {
    
}


- (void)openLandscaping {
    
}


- (void)openFrontCamera {
    videoShowView.cameraPostion = CameraPositionFront;
}


- (void)openBackCamera {
    videoShowView.cameraPostion = CameraPositionBack;
}


#pragma mark
#pragma mark-- BottomViewDelegate

- (void)starRecordWithFilePath:(NSString*)filePath {
    [progressView stopIndicatorAnimation];
    [videoShowView.taker startRecordingToOutputFilePath:filePath];
}

- (void)stopCurrentVideoRecording {
    [progressView starIndicatorAniamtion];
    [videoShowView.taker stopCurrentVideoRecording];
}

- (void)willDeleteLastVideo {
    [progressView setLastProgressToStyle:ProgressBarProgressStyleDelete];
}

- (void)didDeleteLastVideo {
    [progressView removeLastProgressView];
    [self setBottomStatusWithTotalDuration:progressView.totalDuration];
    [videoShowView.taker deleteLastVideo];
}

- (void)mergeVideo {
    [activity startAnimating];
    [videoShowView.taker mergeVideoFiles];
}

#pragma mark
#pragma mark-- VideoTakerDelegate
- (void)videoRecorder:(VideoTaker *)videoRecorder
didStartRecordingToOutPutFileAtURL:(NSURL *)fileURL {
    [progressView addProgressView];
    [bottomView setDeleteStyle:DeleteButtonStyleNormal];
}

- (void)videoRecorder:(VideoTaker *)videoRecorder
didFinishRecordingToOutPutFileAtURL:(NSURL *)outputFileURL
             duration:(CGFloat)videoDuration
             totalDur:(CGFloat)totalDur
                error:(NSError *)error {
    
    [self setBottomStatusWithTotalDuration:totalDur];
}


- (void)videoRecorder:(VideoTaker *)videoRecorder
didRecordingToOutPutFileAtURL:(NSURL *)outputFileURL
             duration:(CGFloat)videoDuration
recordedVideosTotalDur:(CGFloat)totalDur {
    
    [progressView setLastProgressToWidth:videoDuration / _maxDuration * progressView.frame.size.width
                                lastTime:videoDuration
                               totleTime:totalDur+videoDuration];
    
}

- (void)videoRecorder:(VideoTaker *)videoRecorder
didRemoveVideoFileAtURL:(NSURL *)fileURL
             totalDur:(CGFloat)totalDur
                error:(NSError *)error {
    
}

- (void)videoRecorder:(VideoTaker *)videoRecorder
didFinishMergingVideosToOutPutFileAtURL:(NSURL *)outputFileURL {
    
    [activity stopAnimating];
    
    if (_delegate && [_delegate respondsToSelector:@selector(didFinishMergingVideosToOutPut:fileAtURL:videoSize:)]) {
        [_delegate didFinishMergingVideosToOutPut:self fileAtURL:outputFileURL videoSize:_videoSize];
    }
//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//    [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL
//                                completionBlock:^(NSURL *assetURL, NSError *error) {
//                                    if (error) {
//                                        NSLog(@"Save video fail:%@",error);
//                                    } else {
//                                        NSLog(@"Save video succeed.");
//                                    }
//                                }];
}



@end
