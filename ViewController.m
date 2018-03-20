//
//  ViewController.m
//  TakeVideo
//
//  Created by heyk on 18/4/2016.
//  Copyright © 2016 heyk. All rights reserved.
//

#import "ViewController.h"
#import "TakeShortVideoController.h"
#import "VideoPlayController.h"

@interface ViewController ()<TakeShortVideoControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myView.layer.masksToBounds  = NO;
    self.myView.layer.borderColor = [UIColor redColor].CGColor ;
    self.myView.layer.borderWidth = 1;
    
    self.myView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.myView.layer.shadowOffset = CGSizeMake(0, -5);
    self.myView.layer.shadowOpacity = 0.5;
    self.myView.layer.shadowRadius = 8.0;
   // self.myView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 240, 10)].CGPath;
    
    //[UIBezierPath bezierPathWithRoundedRect:self.container.bounds cornerRadius:100.0].CGPath;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickTakeVideo:(id)sender {
    

    TakeShortVideoController *vc = [[TakeShortVideoController alloc] initWithMinDuration:2 maxDuration:20];
    vc.waterPosition = WatermarkPositionBottomRight;
    vc.waterImage = [UIImage imageNamed:@"Icon_57"];
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark TakeShortVideoControllerDelegate
- (void)didFinishMergingVideosToOutPut:(UIViewController*)controller fileAtURL:(NSURL*)videoPath videoSize:(CGSize)videoSize {

    VideoPlayController *vc = [[VideoPlayController alloc] initWithVideoPath:videoPath videoSize:videoSize];
    [controller.navigationController pushViewController:vc animated:YES];
}

@end
