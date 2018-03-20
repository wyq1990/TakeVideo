//
//  RecordTimeTipView.m
//  TakeVideo
//
//  Created by heyk on 21/4/16.
//  Copyright © 2016年 成都好房通股份科技有限公司. All rights reserved.
//

#import "RecordTimeTipView.h"
#import "Masonry.h"

@interface RecordTimeTipView()


@end

@implementation RecordTimeTipView {

    UIImageView *backImageView; // 背景图
    UILabel *contentLabel; // 时间text
}

- (void)dealloc {
    
    NSLog(@"RecordTimeTipView dealloc ====");
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.backgroundColor = [UIColor  clearColor];
    UIImage *image = [UIImage imageNamed:@"resource.bundle/record_progress_arrow_left"];
    backImageView = [[UIImageView alloc] initWithImage:[image stretchableImageWithLeftCapWidth:image.size.width/2 topCapHeight:image.size.height/2]];
    [self addSubview:backImageView];
    
    contentLabel = [[UILabel alloc] init];
    contentLabel.text = @"0秒";
    contentLabel.textColor = [UIColor whiteColor];
    contentLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:contentLabel];
    
    [backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
    
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(5);
        make.right.equalTo(self).offset(-5);
        make.top.equalTo(self).offset(10);
        make.bottom.equalTo(self).offset(-5);
    }];
}

- (void)setCurrentSeconds:(float)seconds {
    contentLabel.text = [NSString stringWithFormat:@"%0.2f秒",seconds];
}

- (void)showLeftTip {
    UIImage *image = [UIImage imageNamed:@"resource.bundle/record_progress_arrow_left"];
    backImageView.image = [image stretchableImageWithLeftCapWidth:image.size.width/2 topCapHeight:image.size.height/2];
}

- (void)showRightTip {
    UIImage *image = [UIImage imageNamed:@"resource.bundle/record_progress_arrow_right"];
    backImageView.image = [image stretchableImageWithLeftCapWidth:image.size.width/2 topCapHeight:image.size.height/2];
}

@end
