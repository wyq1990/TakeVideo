//
//  VideoFileEnginer.m
//  TakeVideo
//
//  Created by heyk on 20/4/16.
//  Copyright © 2016年 成都好房通股份科技有限公司. All rights reserved.
//

#import "VideoFileEnginer.h"

#define kVIDEO_FOLDER @"VIDEO_FOLDER"

@implementation VideoFileEnginer

+ (BOOL)checkVidoDirctory:(NSString*) path {
    BOOL bDirectory = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&bDirectory]) {
        BOOL bSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:path
                                                  withIntermediateDirectories:YES
                                                                   attributes:nil
                                                                        error:nil];
        if (!bSuccess) {
            return NO;
        }
    }
    return YES;
}

+ (NSString *)getVideoMergeFilePathString
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    path = [path stringByAppendingPathComponent:kVIDEO_FOLDER];
    if (![self checkVidoDirctory:path]) {
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *fileName = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"merge.mp4"];
    
    return fileName;
}

+ (NSString *)getVideoSaveFilePathString
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    path = [path stringByAppendingPathComponent:kVIDEO_FOLDER];
    
    if (![self checkVidoDirctory:path]) {
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *fileName = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@".mp4"];
    
    return fileName;
}

@end
