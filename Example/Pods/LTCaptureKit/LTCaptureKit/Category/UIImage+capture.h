//
//  UIImage+capture.h
//  ppz_businessman
//
//  Created by Zero on 2018/10/17.
//  Copyright © 2018年 paipaizhuan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>

@interface UIImage (capture)
+ (UIImage *)imageFromCMSampleBufferRef:(CMSampleBufferRef)sampleBuffer;

+ (UIImage *)imageFromCMSampleBufferRef_RGB:(CMSampleBufferRef)sampleBuffer orientation:(AVCaptureVideoOrientation)avcaptureOrientation;

+ (UIImage *)imageFromCMSampleBufferRef_YUV:(CMSampleBufferRef)sampleBuffer;

//拍照返回的 宽 高 和 准备切除的四周的相对屏幕尺寸的点
//计算实际要切除的像素大小（屏幕320*640类似，但拍照时1920*1080）
+ (UIEdgeInsets)pixelInsetsFromWidth:(size_t)width height:(size_t)height insets:(UIEdgeInsets)insets;
/*
 剪裁：
 软剪
 硬剪，硬剪没完全调试成功，但是可以输出照片
 */
+ (CMSampleBufferRef)cropSampleBufferBySoftware:(CMSampleBufferRef)sampleBuffer insets:(UIEdgeInsets)insets;

+ (CMSampleBufferRef)cropSampleBufferByHardware:(CMSampleBufferRef)buffer;

@end
