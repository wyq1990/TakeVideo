//
//  BottomView.m
//  TakeVideo
//
//  Created by heyk on 20/4/16.
//  Copyright © 2016年 成都好房通股份科技有限公司. All rights reserved.
//

#import "BottomView.h"
#import "Masonry.h"
#import "VideoFileEnginer.h"

@implementation BottomView {

    BOOL bRecordButtonPressed;
}

- (void)dealloc {
    
    NSLog(@"BottomView dealloc ====");
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
        self.deleteButton.hidden = YES;
        self.doneButton.hidden = YES;
    }
    return self;
}


- (void)setUI {
    
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //
    [_deleteButton setImage:[UIImage imageNamed:@"resource.bundle/record_ico_delete"] forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(clickDelete:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_deleteButton];
    
    self.recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_recordButton setImage:[UIImage imageNamed:@"resource.bundle/record_ico_rec_push"] forState:UIControlStateNormal];
    _recordButton.userInteractionEnabled = NO;
    [self addSubview:_recordButton];
    
    self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_doneButton setImage:[UIImage imageNamed:@"resource.bundle/dub_ico_confirm"] forState:UIControlStateNormal];
    [_doneButton setImage:[UIImage imageNamed:@"resource.bundle/dub_ico_confirm_1"] forState:UIControlStateHighlighted];
    [_doneButton setImage:[UIImage imageNamed:@"resource.bundle/record_ico_confirm_dis"] forState:UIControlStateDisabled];
    [_doneButton addTarget:self action:@selector(clickDone:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_doneButton];
    
    _deleteStyle = DeleteButtonStyleNormal;
    [_recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self.mas_left).offset(30);
    }];
    
    [_doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self.mas_right).offset(-30);
    }];
    
}

- (void)setDeleteStyle:(DeleteButtonStyle)deleteStyle {
    _deleteStyle = deleteStyle;
    if (deleteStyle == DeleteButtonStyleDelete) {
        _deleteButton.enabled = YES;
        [_deleteButton setImage:[UIImage imageNamed:@"resource.bundle/record_ico_delete_1"] forState:UIControlStateNormal];
    }
    else if(deleteStyle == DeleteButtonStyleNormal){
        _deleteButton.enabled = YES;
        [_deleteButton setImage:[UIImage imageNamed:@"resource.bundle/record_ico_delete"] forState:UIControlStateNormal];
    }
    else if(deleteStyle == DeleteButtonStyleDisable){
        [_deleteButton setImage:[UIImage imageNamed:@"resource.bundle/record_ico_delete"] forState:UIControlStateNormal];
        _deleteButton.enabled = NO;
    }
}

#pragma mark
#pragma mark-- click methods

- (void)clickDelete:(UIButton*)button {
    if (_deleteStyle == DeleteButtonStyleNormal) {
        self.deleteStyle = DeleteButtonStyleDelete;
        
        if (_delegate && [_delegate respondsToSelector:@selector(willDeleteLastVideo)]) {
            [_delegate willDeleteLastVideo];
        }
    }
    else {
        self.deleteStyle = DeleteButtonStyleNormal;
        if (_delegate && [_delegate respondsToSelector:@selector(didDeleteLastVideo)]) {
            [_delegate didDeleteLastVideo];
        }
    }
}


- (void)clickDone:(UIButton*)button {
    if(_delegate && [_delegate  respondsToSelector:@selector(mergeVideo)]){
        [_delegate mergeVideo];
    }
}


#pragma mark
#pragma mark-- touch events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    CGPoint touchPoint = [touch locationInView:self];
    if (CGRectContainsPoint(_recordButton.frame, touchPoint)) {
        bRecordButtonPressed = YES;
        
        [_recordButton setImage:[UIImage imageNamed:@"resource.bundle/record_ico_rec"] forState:UIControlStateNormal];
        NSString *filePath = [VideoFileEnginer getVideoSaveFilePathString];
        if (_delegate && [_delegate respondsToSelector:@selector(starRecordWithFilePath:)]) {
            [_delegate starRecordWithFilePath:filePath];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (bRecordButtonPressed) {
        bRecordButtonPressed = NO;
        
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:self];
        if (CGRectContainsPoint(_recordButton.frame, touchPoint)) {
            
            [_recordButton setImage:[UIImage imageNamed:@"resource.bundle/record_ico_rec_push"] forState:UIControlStateNormal];
            if (_delegate && [_delegate respondsToSelector:@selector(stopCurrentVideoRecording)]) {
                [_delegate stopCurrentVideoRecording];
            }
        }
    }
}

- (void)touchesCancelled:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {

    NSLog(@"--touchesCancelled-");
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    if (bRecordButtonPressed) {
        CGPoint touchPoint = [touch locationInView:self];
        if (!CGRectContainsPoint(_recordButton.frame, touchPoint)) {
            bRecordButtonPressed = NO;
            
            [_recordButton setImage:[UIImage imageNamed:@"resource.bundle/record_ico_rec_push"] forState:UIControlStateNormal];
            if (_delegate && [_delegate respondsToSelector:@selector(stopCurrentVideoRecording)]) {
                [_delegate stopCurrentVideoRecording];
            }
        }
    }
}

@end
