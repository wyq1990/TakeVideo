//
//  VideoPlayView.m
//  Erp4iOS
//
//  Created by 开发者 on 16/4/12.
//  Copyright © 2016年 成都好房通科技有限公司. All rights reserved.
//

#import "VideoPlayView.h"
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"
#import "VideoPlayToolBar.h"
#import "VideoLoadingView.h"
#import "UIWindow+Category.h"

#define kDeviceWidth [UIScreen mainScreen].bounds.size.width
#define KDeviceHeight [UIScreen mainScreen].bounds.size.height
#define KDeviceFrame [UIScreen mainScreen].bounds

@interface VideoPlayView()<VideoPlayToolBarDelegate>{
    
    CGAffineTransform   lastTransform;
    UIButton            *closeButton;
    AVPlayerItem        *playerItem;
    AVPlayerLayer       *playerLayer;
    id                  timeObserver;
    
    __weak UIView       *superView;
    CGRect              oldFrame;
}
@property (nonatomic, strong) VideoPlayToolBar *toolBar;// 底部工具栏
@property (nonatomic, strong) VideoLoadingView *loadView;// 加载进度
@property (nonatomic, strong) AVPlayer *player;// 播放器对象
@property (nonatomic, strong) NSString *videoURL;// 视频地址
@property (nonatomic, strong) NSURL *videoPath;// 视频本地路径地址
@property (nonatomic, assign) BOOL     bHavePlayOver;// 已经播放完
@property (nonatomic, assign) BOOL     isFullscreen;// 是否全屏
@end


@implementation VideoPlayView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"VideoPlayViewController === 释放");
}

- (id)initWithVideoURL:(NSString*)url {
    self = [super init];
    if (self) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        self.videoURL = url;
        // 初始化页面
        self.backgroundColor = [UIColor blackColor];
        
        // 播放结束通知
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(playEnd)
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
        
        // 播放失败
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(playInterrupt)
                                                    name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                  object:nil];
        
        // 监听方向变化
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(tap)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (id)initWithVideoContentPath:(NSURL*)path {
    
    self = [super init];
    if (self) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        self.videoPath = path;
        // 初始化页面
        self.backgroundColor = [UIColor blackColor];
        
        // 播放结束通知
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(playEnd)
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
        
        // 播放失败
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(playInterrupt)
                                                    name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                  object:nil];
        
        // 监听方向变化
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(tap)];
        [self addGestureRecognizer:tap];
    }
    return self;
    
}


#pragma mark
#pragma mark-- 自定义方法 私有方法
// 初始化UI
-(void)setupUI {
    
    // 创建播放器层
    if(_videoURL) {
        NSString *urlStr =[_videoURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:urlStr]];
        
    }
    else if(_videoPath){
        
        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:_videoPath options:nil];
        playerItem = [AVPlayerItem playerItemWithAsset:urlAsset];;
        
    }
    else return;
    
    
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    
    [self addProgressObserver];
    [self addObserverToPlayerItem:playerItem];
    
    playerLayer=[AVPlayerLayer playerLayerWithPlayer:_player];
    playerLayer.frame = self.bounds;
    [self.layer addSublayer:playerLayer];
    
    
    self.loadView = [[VideoLoadingView alloc] init];
    [self addSubview:_loadView];
    
    closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *closeImage = [UIImage imageNamed:@"video_close"];
    [closeButton setImage:closeImage  forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
    
    self.toolBar = [[VideoPlayToolBar alloc] init];
    self.toolBar.delegate = self;
    [self addSubview:_toolBar];
    
    // 布局
    __weak typeof(self) weakSelf = self;
    float closeButtonWidth = closeImage.size.width + 20;
    float closeButtonHeight = closeImage.size.width + 30;
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(weakSelf.mas_right).offset(-10);
        make.top.equalTo(weakSelf.mas_top);
        make.height.equalTo([NSNumber numberWithFloat:closeButtonHeight]);
        make.width.equalTo([NSNumber numberWithFloat:closeButtonWidth]);
    }];
    
    [_loadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakSelf);
    }];
    
    [_toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(weakSelf.mas_right);
        make.left.equalTo(weakSelf.mas_left);
        make.bottom.equalTo(weakSelf.mas_bottom);
        make.height.equalTo(@35);
    }];
    if (_bHiddenCloseButton){
        closeButton.hidden = YES;
    }
}

- (void)close {
    if (_player) {
        [_player pause];
    }
    [_toolBar stopTimer];
    [self removeObserverFromPlayerItem:playerItem];
    [self.player removeTimeObserver:timeObserver];
    [self removeFromSuperview];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)tap {
    [_toolBar showOrHidden];
}

- (void)setBHiddenCloseButton:(BOOL)bHiddenCloseButton {

    _bHiddenCloseButton = bHiddenCloseButton;
    closeButton.hidden = bHiddenCloseButton;
}
#pragma mark
#pragma mark-- 公共方法
- (void)showOnView:(UIView*)view {
    [self showOnView:view frame:view.bounds];
}

- (void)showOnView:(UIView*)view frame:(CGRect)frame {
    self.frame = frame;
    [view addSubview:self];
    
    // 记录初始值，退出全屏后需要
    superView = view;
    oldFrame = self.frame;
    
    // 设置UI
    [self setupUI];
    [_loadView startAnimation];
    
    // 主动触发播放
    [_toolBar play];

    
}

- (void)showOnWindowWithMinSize:(CGSize)size {
    self.frame = CGRectMake(0, 64, size.width, size.height);
    UIView *window = [[UIApplication sharedApplication].windows lastObject];
    [window addSubview:self];
    
    // 记录初始值，退出全屏后需要
    superView = window;
    oldFrame = self.frame;
    
    // 设置UI
    [self setupUI];
    [_loadView startAnimation];
    
    // 主动触发播放
    [_toolBar play];
}


- (void)dismiss {
    if (_isFullscreen) {
        [self doHiddenFullScreenAnimation:^(BOOL finish) {
            [self close];
            
        }];
    }
    else{
        [self close];
    }
}


#pragma mark
#pragma mark-- 监控

// 给播放器添加进度更新
-(void)addProgressObserver {
    __weak typeof(self) weakSelf = self;
    //这里设置每秒执行10次
    timeObserver =  [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 5.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current = CMTimeGetSeconds(time);
        
        if(weakSelf.toolBar.isPlaying) {
            weakSelf.toolBar.slider.value = current;
            [weakSelf.toolBar setplayedTime:current];
        }
    }];
}

// 给AVPlayerItem添加监控
-(void)addObserverToPlayerItem:(AVPlayerItem *)aplayerItem {
    
    // 监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [aplayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 监控网络加载情况属性
    [aplayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
}

-(void)removeObserverFromPlayerItem:(AVPlayerItem *)aplayerItem {
    [aplayerItem removeObserver:self forKeyPath:@"status"];
    [aplayerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    
}

// 通过KVO监控播放器状态
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {// 播放状态改变
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        
        if(status==AVPlayerStatusReadyToPlay){
            
            float total = CMTimeGetSeconds([playerItem duration]);
            _toolBar.slider.minimumValue = 0;
            _toolBar.slider.maximumValue = total;
            
            [_toolBar setTotleTime:total];
            [_loadView stopAnimation];
            
        }
        
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]) { // 缓冲进度
        
        NSArray *array=playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];// 本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;// 缓冲总长度
        
        [_toolBar setCacheProgress:totalBuffer];
        
        if ([self isPlaying]) {
            [_player play];
        }
        if (totalBuffer == CMTimeGetSeconds([playerItem duration])) {
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    }
}

#pragma mark
#pragma mark-- VideoPlayToolBarDelegate

- (void)startPlay {
    if(_bHavePlayOver) {
        
        [_player seekToTime:CMTimeMake(0, 10)];
        _bHavePlayOver = NO;
    }
    
    [_player play];
}

- (void)pause {
    [_player pause];
}

// 改变播放进度中
- (void)changeProgress:(float)progress {
    // [_player pause];
}

// 改变播放进度结束
- (void)didEndChangeProgress {
    __weak typeof(self) weakSelf = self;
    [_player seekToTime:CMTimeMakeWithSeconds(_toolBar.currentProgress, 1)
        toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero
      completionHandler:^(BOOL finished) {
          
          weakSelf.bHavePlayOver = NO;
          weakSelf.toolBar.isPlaying = YES;
          [weakSelf.toolBar play];
      }];
    
}

// 点击进入全屏
- (void)showFullScreen {
    _isFullscreen = YES;
    [self doShowFullScreenAnimation:CGAffineTransformMakeRotation(M_PI * 0.5)];
}

// 执行进入全屏动画
- (void)doShowFullScreenAnimation:(CGAffineTransform)newTrans {
    
    UIWindow *window = [[UIApplication   sharedApplication].delegate window];
    UIViewController *vc = [window currentViewController];
    vc.navigationController.navigationBarHidden = YES;
    
//
//    [self bringSubviewToFront:[[UIApplication sharedApplication] keyWindow]];
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.transform = CGAffineTransformIdentity;
                         self.frame = CGRectMake(0, 0, KDeviceHeight, kDeviceWidth);
                         playerLayer.frame = self.bounds;
                         self.center = [[UIApplication sharedApplication] keyWindow].center;
                         self.transform = newTrans;
                         
                     } completion:^(BOOL finished) {
                         [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                                 withAnimation:UIStatusBarAnimationSlide];
                         closeButton.hidden = YES;
                         [self.toolBar showFullStatus];
                     }];
}


// 点击退出全屏
- (void)hiddenFullScreen {
    _isFullscreen = NO;
    [self doHiddenFullScreenAnimation:nil];
}

// 执行退出全屏动画
- (void)doHiddenFullScreenAnimation:(void (^)(BOOL finish))block {
//    [self bringSubviewToFront:superView];
    
    UIWindow *window = [[UIApplication   sharedApplication].delegate window];
    UIViewController *vc = [window currentViewController];
     vc.navigationController.navigationBarHidden = NO;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         
                         self.transform = CGAffineTransformIdentity;
                         self.frame = oldFrame;
                         playerLayer.frame = self.bounds;
                         
                     }
                     completion:^(BOOL finished) {
                         
                         [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                                 withAnimation:UIStatusBarAnimationSlide];
                          closeButton.hidden = _bHiddenCloseButton;
                         [self.toolBar showMinStatus];
                         
                         if (block) {
                             block(YES);
                         }
                     }];
}

#pragma mark
#pragma mark-- 播放器状态

- (BOOL)isPlaying{
    
    //   return _toolBar.isPlaying;
    if (_player) {
        if (_player.rate == 1.0) {
            return YES;
        }
        return NO;
    }
    return NO;
}

#pragma mark
#pragma mark-- 通知

// 播放完成
- (void)playEnd {
    _bHavePlayOver = YES;
    [_toolBar pause];
    if (self.delegate && [self.delegate respondsToSelector:@selector(playDidEnd:)]) {
        [_delegate playDidEnd:self];
    }
}

// 播放中断
- (void)playInterrupt {
    [_toolBar play];
}

// 设备方向改变
- (void)orientationChanged {
    [self reloatePlayerView:[[UIDevice currentDevice] orientation] animation:YES];
}


#pragma mark
#pragma mark-- 旋转

- (void)reloatePlayerView:(UIDeviceOrientation)deviceOrientation animation:(BOOL)bAnimation {
    if(deviceOrientation == UIDeviceOrientationFaceUp ||
       deviceOrientation == UIDeviceOrientationFaceDown ||
       deviceOrientation == UIDeviceOrientationPortraitUpsideDown ||
       deviceOrientation == UIDeviceOrientationUnknown)
        return;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
        _isFullscreen = YES;
        transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    else if(deviceOrientation == UIDeviceOrientationLandscapeRight){
        _isFullscreen = YES;
        transform = CGAffineTransformMakeRotation(-M_PI_2);
    }
    else{
        _isFullscreen = NO;
    }
    
    //如果方向没有变化就不执行动画
    if (self.transform.a == transform.a &&
        self.transform.b == transform.b &&
        self.transform.c == transform.c &&
        self.transform.d == transform.d &&
        self.transform.tx == transform.tx &&
        self.transform.ty == transform.ty) {
        
        return;
    }
    if (_isFullscreen) {
        [self doShowFullScreenAnimation:transform];
    }
    else{
        [self doHiddenFullScreenAnimation:nil];
    }
}



@end
