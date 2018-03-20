//
//  TakeVideo.h
//  TakeVideo
//
//  Created by heyk on 20/4/16.
//  Copyright © 2016年 成都好房通股份科技有限公司. All rights reserved.
//

#ifndef TakeVideo_h
#define TakeVideo_h


typedef NS_ENUM(NSInteger,WatermarkPosition){
    WatermarkPositionTopRight,// 右上角
    WatermarkPositionBottomRight,// 右下角
    WatermarkPositionBottomLeft,// 左下角
    WatermarkPositionTopLeft,// 左上角
};

typedef NS_ENUM(NSInteger,CameraPosition){
    CameraPositionBack,
    CameraPositionFront,
};


#define kCAMERAFLASHAUTOCHANGED @"kCAMERAFLASHAUTOCHANGED" // 摄像头闪光灯自动开关

#endif /* TakeVideo_h */
