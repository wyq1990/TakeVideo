//
//  VideoPlayController.m
//  TakeVideo
//
//  Created by heyk on 4/5/16.
//  Copyright © 2016年 成都好房通股份科技有限公司. All rights reserved.
//

#import "VideoPlayController.h"
#import "VideoPlayView.h"

@interface VideoPlayController()<VideoPlayViewDelegate> {
    
    VideoPlayView * videoPlay;
}

@property (nonatomic, copy) NSURL *videoPath;
@property (nonatomic ,assign) CGSize videoSize;

@end


@implementation VideoPlayController {

}
- (void)dealloc {
    [videoPlay dismiss];
}

- (id)initWithVideoPath:(NSURL*)path videoSize:(CGSize)size {

    self = [super init];
    if (self) {
        self.videoPath = path;
        self.videoSize = size;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.videoPath) {
        
        NSString *url = @"http://video4.myfun7.com/0/2015/11/21/9fe32030f681790fad048ded30226675.mp4";
        videoPlay = [[VideoPlayView alloc] initWithVideoURL:url];
//        videoPlay = [[VideoPlayView alloc] initWithVideoContentPath:self.videoPath];
        videoPlay.delegate = self;
        videoPlay.bHiddenCloseButton = YES;
        [videoPlay showOnView:self.view frame:CGRectMake(0,64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*_videoSize.height/_videoSize.width)];
    }
}


#pragma mark VideoPlayViewDelegate
- (void)playDidEnd:(VideoPlayView*)view {

}


@end
