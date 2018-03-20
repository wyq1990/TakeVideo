//
//  TakeVideoNavBar.m
//  TakeVideo
//
//  Created by heyk on 19/4/2016.
//  Copyright © 2016 成都好房通股份科技有限公司. All rights reserved.
//

#import "TakeVideoNavBar.h"
#import "Masonry.h"

@implementation TakeVideoNavBar {

    UIButton *flashButton;
    UIButton *landscapingButton;
    UIButton *cameraFrontButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)dealloc {

    NSLog(@"TakeVideoNavBar dealloc ====");
}

- (instancetype)initWithFrame:(CGRect)frame
       withDelegate:(id<TakeVideoNavBarDelegate>)delegate {
    
    self = [super initWithFrame: frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.enableChangeCamraPositon = YES;
        self.delegate = delegate;
        [self initUI];
        [self defaultSetting];
    }
    return self;
}

- (id)init {

    self = [super init];
    if (self) {
        
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
        [self initUI];
        [self defaultSetting];
    }
    return self;
}

- (void)initUI {
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[UIImage imageNamed:@"resource.bundle/cancel"] forState:UIControlStateNormal];
    closeButton.frame = CGRectMake(0, 0, 60, self.frame.size.height);
    [closeButton addTarget:self action:@selector(clickClose:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
    
    flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [flashButton setImage:[UIImage imageNamed:@"resource.bundle/record_ico_flashlight"] forState:UIControlStateNormal];
    [flashButton setImage:[UIImage imageNamed:@"resource.bundle/record_ico_flashlight_1"] forState:UIControlStateSelected];
    [flashButton addTarget:self action:@selector(clickFlash:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:flashButton];
    
    landscapingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [landscapingButton setImage:[UIImage imageNamed:@"resource.bundle/record_ico_mackup"] forState:UIControlStateNormal];
    [landscapingButton setImage:[UIImage imageNamed:@"resource.bundle/record_ico_mackup_1"] forState:UIControlStateSelected];
    [landscapingButton addTarget:self action:@selector(clickLachscaping:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:landscapingButton];
    
    cameraFrontButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraFrontButton setImage:[UIImage imageNamed:@"resource.bundle/record_ico_switch"] forState:UIControlStateNormal];
    [cameraFrontButton setImage:[UIImage imageNamed:@"resource.bundle/record_ico_switch_1"] forState:UIControlStateSelected];
    [cameraFrontButton addTarget:self action:@selector(clickChangeCameraFront:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cameraFrontButton];

    self.enableFlash = YES;
    self.enableLandscaping = YES;
    self.enableChangeCamraPositon = YES;
}

- (void)defaultSetting {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveCameraFlashChanged:) name:kCAMERAFLASHAUTOCHANGED object:nil];
}



#pragma mark
#pragma mark-- setter 方法

- (void)setEnableFlash:(BOOL)enableFlash {
    _enableFlash = enableFlash;
    if (enableFlash) {
        flashButton.hidden = NO;
    }
    else{
        flashButton.hidden = YES;
    }
    
    [flashButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
        make.width.equalTo(@60);
    }];
}

- (void)setEnableLandscaping:(BOOL)enableLandscaping {
    _enableLandscaping = enableLandscaping;
    if (enableLandscaping) {
        landscapingButton.hidden = NO;
        
        [landscapingButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
            make.width.equalTo(@60);
            make.left.equalTo(flashButton.mas_right);
            make.right.equalTo(cameraFrontButton.mas_left);
        }];
    }
    else{
        landscapingButton.hidden = YES;
        
        [landscapingButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
            make.width.equalTo(@0);
            make.left.equalTo(flashButton.mas_right);
            make.right.equalTo(cameraFrontButton.mas_left);
        }];
    }
}


- (void)setEnableChangeCamraPositon:(BOOL)enableChangeCamraPositon {
    _enableChangeCamraPositon = enableChangeCamraPositon;
    if (enableChangeCamraPositon) {
        
        cameraFrontButton.hidden = NO;
        [cameraFrontButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
            make.width.equalTo(@60);
            make.right.equalTo(self.mas_right);
        }];
    }
    else{
        cameraFrontButton.hidden = YES;
        [cameraFrontButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
            make.width.equalTo(@0);
            make.right.equalTo(self.mas_right);
        }];
    }
}

- (void)setDefaultCameraPostion:(CameraPosition)defaultCameraPostion {
    _defaultCameraPostion = defaultCameraPostion;
    if (_defaultCameraPostion == CameraPositionFront) {
        cameraFrontButton.selected = YES;
    }
    else {
        cameraFrontButton.selected = NO;
    }
}

#pragma mark
#pragma mark-- 点击方法
- (void)clickClose:(UIButton*)button {

    if (self.delegate && [_delegate respondsToSelector:@selector(closeWindow)]) {
        [_delegate closeWindow];
    }
}

- (void)clickFlash:(UIButton*)button {
    button.selected = !button.selected;
    if (button.selected) {//开启闪光灯
        if(_delegate && _delegate){
            [_delegate openFlash];
        }
    }
    else{//关闭闪光灯
        if(_delegate && _delegate){
            [_delegate closeFlash];
        }
    }

}

- (void)clickLachscaping:(UIButton*)button {
    button.selected = !button.selected;
    if (button.selected) {//开启美化
        if(_delegate && _delegate){
            [_delegate openLandscaping];
        }
    }
    else{//关闭闪美化
        if(_delegate && _delegate){
            [_delegate closeLandscaping];
        }
    }
}

- (void)clickChangeCameraFront:(UIButton*)button {
    button.selected = !button.selected;
    if (button.selected) {//前置摄像头
        if(_delegate && _delegate){
            [_delegate openFrontCamera];
        }
    }
    else{//后置摄像头
        if(_delegate && _delegate){
            [_delegate openBackCamera];
        }
    }
}

#pragma mark
#pragma mark-- notify
- (void)recieveCameraFlashChanged:(NSNotification*)notify {
    BOOL bOpen = [[notify object] boolValue];
    if (bOpen) flashButton.selected = YES;
    else flashButton.selected = NO;
}
@end
