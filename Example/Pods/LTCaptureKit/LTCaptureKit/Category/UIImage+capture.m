//
//  UIImage+capture.m
//  ppz_businessman
//
//  Created by Zero on 2018/10/17.
//  Copyright © 2018年 paipaizhuan. All rights reserved.
//
#define clamp(a) (a>255?255:(a<0?0:a));

#import "Endian.h"
#import "UIImage+capture.h"

@implementation UIImage (capture)

+ (UIImage *)imageFromCMSampleBufferRef:(CMSampleBufferRef)sampleBuffer {
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CIImage *ciImage=[CIImage imageWithCVPixelBuffer:imageBuffer];
    
    UIImage *image = [UIImage imageWithCIImage:ciImage];
    
    return image;
}

+ (UIImage *)imageFromCMSampleBufferRef_RGB:(CMSampleBufferRef)sampleBuffer orientation:(AVCaptureVideoOrientation)avcaptureOrientation {
    
    /*
     avfoundtion获取的视频流，默认就是旋转了90度的
     */
    UIImageOrientation orientation = UIImageOrientationUp;
    if (avcaptureOrientation == AVCaptureVideoOrientationPortrait) {
        orientation = UIImageOrientationRight;
    } else if (avcaptureOrientation == AVCaptureVideoOrientationPortraitUpsideDown) {
        orientation = UIImageOrientationLeft;
    } else if (avcaptureOrientation == AVCaptureVideoOrientationLandscapeLeft) {
        orientation = UIImageOrientationDown;
    } else if (avcaptureOrientation == AVCaptureVideoOrientationLandscapeRight) {
        orientation = UIImageOrientationUp;
    }
    
    CVImageBufferRef imageBuffer =  CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    uint8_t *baseAddress =CVPixelBufferGetBaseAddress(imageBuffer);
    size_t width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0);
    size_t height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    CGColorSpaceRef colorSpace= CGColorSpaceCreateDeviceRGB();
    CGContextRef cgContext= CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(cgContext);
    UIImage *image=[UIImage imageWithCGImage:cgImage scale:1.0 orientation:orientation];
    
    CGImageRelease(cgImage);
    CGContextRelease(cgContext);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return image;
}

+ (UIImage *)imageFromCMSampleBufferRef_YUV:(CMSampleBufferRef)sampleBuffer {
    
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    // Get the number of bytes per row for the plane pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    // Get the number of bytes per row for the plane pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer,0);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    //    size_t width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0);
    //    size_t height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0);
    
    // Create a device-dependent gray color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGImageAlphaNone);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    // Release the Quartz image
    CGImageRelease(quartzImage);
    return (image);
}








+ (size_t)heightTransFromScreen:(size_t)height originHeight:(size_t)originHeight {
    
    CGFloat screen_height = UIScreen.mainScreen.bounds.size.height;
    
    return height * originHeight / screen_height;
}

+ (size_t)widthTransFromScreen:(size_t)width originWidth:(size_t)originWidth {
    
    CGFloat screen_witdth = UIScreen.mainScreen.bounds.size.width;
    
    return width * originWidth / screen_witdth;
}

//拍照返回的 宽 高 和 准备切除的四周的相对屏幕尺寸的点
+ (UIEdgeInsets)pixelInsetsFromWidth:(size_t)width height:(size_t)height insets:(UIEdgeInsets)insets {
    //width 和 height是相反的 width才是真正的高
    
    CGSize screenBounds = UIScreen.mainScreen.bounds.size;
    
    CGFloat ratio_capture = (CGFloat)height / width;
    CGFloat ratio_screen = (CGFloat)screenBounds.width / screenBounds.height;
    
    size_t vertical = 0;
    size_t horizontal = 0;
    
    //ratio_capture大 说明宽长
    if (ratio_capture > ratio_screen) {
        horizontal = height - ratio_screen * width;
    } else if (ratio_capture < ratio_screen){
        vertical = width - (1 / ratio_screen) * height;
    }
    
    //屏幕同步到要切割的像素上
    size_t col_right = [self widthTransFromScreen:insets.right originWidth:height];
    size_t col_left = [self widthTransFromScreen:insets.left originWidth:height];
    size_t row_top = [self heightTransFromScreen:insets.top originHeight:width];
    size_t row_bottom = [self heightTransFromScreen:insets.bottom originHeight:width];
    
    row_top += vertical / 2;
    row_bottom += vertical / 2;
    
    col_left += horizontal / 2;
    col_right += horizontal / 2;
    
    return UIEdgeInsetsMake(row_top, col_left, row_bottom, col_right);
    
}

+ (CMSampleBufferRef)cropSampleBufferBySoftware:(CMSampleBufferRef)sampleBuffer insets:(UIEdgeInsets)insets {
    
    return [self cropSampleBufferBySoftware:sampleBuffer pixelInsetsHandle:^UIEdgeInsets(size_t width, size_t height) {
        
        return [self pixelInsetsFromWidth:width height:height insets:insets];
    }];
}

//pixelInsetsHandle 返回像素切割insets 要切割的实际像素大小
+ (CMSampleBufferRef)cropSampleBufferBySoftware:(CMSampleBufferRef)sampleBuffer pixelInsetsHandle:(UIEdgeInsets(^)(size_t width,size_t height))pixelInsetsHandle {
    OSStatus status;
    
    //    CVPixelBufferRef pixelBuffer = [self modifyImage:buffer];
    CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the image buffer
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    // Get information about the image
    uint8_t *baseAddress     = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t  bytesPerRow      = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t  width            = CVPixelBufferGetWidth(imageBuffer);
    size_t  height           = CVPixelBufferGetHeight(imageBuffer);
    NSInteger bytesPerPixel  =  bytesPerRow/width; //一个像素占几个字节（rgba = 4，yuv = 3）
    
    
    CVPixelBufferRef            pixbuffer = NULL;
    CMVideoFormatDescriptionRef videoInfo = NULL;
    
    size_t width_crop = width;
    size_t height_crop = height;
    
    if (pixbuffer == NULL) {
        
        UIEdgeInsets insets = UIEdgeInsetsZero;
        if (pixelInsetsHandle) {
            insets = pixelInsetsHandle(width,height);
        }
        
        size_t col_right = insets.right;
        size_t col_left = insets.left;
        size_t row_top = insets.top;
        size_t row_bottom = insets.bottom;
        
        size_t start = 0;
        
        /*
         
         &baseAddress(设基地址为0x0)
         row👉   0 1 2 3 ...
         0x0             0x4                      0x n*4
         col        BGRA             BGRA      ...........    BGRA
         👇       row(0)col(0)   row(1)col(0)              row(n)col(0)
         0        row(1)col(1)   row(1)col(1)              row(n)col(1)
         1
         2
         .
         .
         .
         ___________
         |           |
         <-- 图片真实方向|           |
         |           |
         ____________
         
         width * bytesPerPixel 一个row有多少像素 （bytesPerRow）
         col_right * width * bytesPerPixel 相当于右侧切割了多少row
         row_top * bytesPerPixel 相当于偏移了多少个col
         所以总的start 就是上和右的偏移
         */
        start = col_right * width * bytesPerPixel + row_top * bytesPerPixel;
        
        /*
         而下和左 只需要通过减少height和width的值即可实现
         
         数据方向是实际拍照方向左旋转90度，所以height和width相反
         */
        width_crop -= row_top + row_bottom;
        height_crop -= col_right + col_left;
        
#if 0
        //遍历 像素 更好的帮助理解 数据结构
        size_t offset,p;
        int r,g,b,a;
        for (int col = 0; col < height; ++col) {
            for (int row = 0; row < width; ++row) {
                offset = ((width * col) + row);
                p = offset*4;
                
                b = baseAddress[p];
                g = baseAddress[p+1];
                r = baseAddress[p+2];
                a = baseAddress[p+3];
                if (row < row_top || row > width - row_bottom || col < col_right || col > height - col_left) {
                    baseAddress[p] = 255;
                    baseAddress[p+1] = 255;
                    baseAddress[p+2] = 255;
                    baseAddress[p+3] = 255;
                }
            }
        }
        //恢复原始值
        start = 0 ;
        width_crop = width;
        height_crop = height;
#endif
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool : YES],           kCVPixelBufferCGImageCompatibilityKey,
                                 [NSNumber numberWithBool : YES],           kCVPixelBufferCGBitmapContextCompatibilityKey,
                                 nil];
        
        status = CVPixelBufferCreateWithBytes(kCFAllocatorDefault, width_crop, height_crop, kCVPixelFormatType_32BGRA, &baseAddress[start], bytesPerRow, NULL, NULL, (__bridge CFDictionaryRef)options, &pixbuffer);
        if (status != 0) {
            NSLog(@"Crop CVPixelBufferCreateWithBytes error %d",(int)status);
            return NULL;
        }
    }
    
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    CMSampleTimingInfo sampleTime = {
        .duration               = CMSampleBufferGetDuration(sampleBuffer),
        .presentationTimeStamp  = CMSampleBufferGetPresentationTimeStamp(sampleBuffer),
        .decodeTimeStamp        = CMSampleBufferGetDecodeTimeStamp(sampleBuffer)
    };
    
    if (videoInfo == NULL) {
        status = CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixbuffer, &videoInfo);
        if (status != 0) NSLog(@"Crop CMVideoFormatDescriptionCreateForImageBuffer error %d",(int)status);
    }
    
    CMSampleBufferRef cropBuffer = NULL;
    status = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, pixbuffer, true, NULL, NULL, videoInfo, &sampleTime, &cropBuffer);
    if (status != 0) NSLog(@"Crop CMSampleBufferCreateForImageBuffer error %d",(int)status);
    
    CVPixelBufferRelease(pixbuffer);
    CFRelease(videoInfo);
    
    return CFAutorelease(cropBuffer);
}




+ (CMSampleBufferRef)cropSampleBufferByHardware:(CMSampleBufferRef)buffer {
    // a CMSampleBuffer's CVImageBuffer of media data.
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(buffer);
    size_t  width            = CVPixelBufferGetWidth(imageBuffer);
    size_t  height           = CVPixelBufferGetHeight(imageBuffer);
    
    CGFloat _cropX = 0,_cropY = 0,g_width_size,g_height_size;
    g_width_size = width;
    g_height_size = height;
    
    CGRect           cropRect    = CGRectMake(_cropX, _cropY, g_width_size, g_height_size);
    //        log4cplus_debug("Crop", "dropRect x: %f - y : %f - width : %zu - height : %zu", cropViewX, cropViewY, width, height);
    
    /*
     First, to render to a texture, you need an image that is compatible with the OpenGL texture cache. Images that were created with the camera API are already compatible and you can immediately map them for inputs. Suppose you want to create an image to render on and later read out for some other processing though. You have to have create the image with a special property. The attributes for the image must have kCVPixelBufferIOSurfacePropertiesKey as one of the keys to the dictionary.
     如果要进行页面渲染，需要一个和OpenGL缓冲兼容的图像。用相机API创建的图像已经兼容，您可以马上映射他们进行输入。假设你从已有画面中截取一个新的画面，用作其他处理，你必须创建一种特殊的属性用来创建图像。对于图像的属性必须有kCVPixelBufferIOSurfacePropertiesKey 作为字典的Key.因此以下步骤不可省略
     */
    
    OSStatus status;
    
    /* Only resolution has changed we need to reset pixBuffer and videoInfo so that reduce calculate count */
    static CVPixelBufferRef            pixbuffer = NULL;
    static CMVideoFormatDescriptionRef videoInfo = NULL;
    
    if (pixbuffer == NULL) {
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithInt:g_width_size],     kCVPixelBufferWidthKey,
                                 [NSNumber numberWithInt:g_height_size],    kCVPixelBufferHeightKey, nil];
        status = CVPixelBufferCreate(kCFAllocatorSystemDefault, g_width_size, g_height_size, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)options, &pixbuffer);
        // ensures that the CVPixelBuffer is accessible in system memory. This should only be called if the base address is going to be used and the pixel data will be accessed by the CPU
        if (status != noErr) {
            NSLog(@"Crop CVPixelBufferCreate error %d",(int)status);
            return NULL;
        }
    }
    
    CIImage *ciImage = [CIImage imageWithCVImageBuffer:imageBuffer];
    ciImage = [ciImage imageByCroppingToRect:cropRect];
    // Ciimage get real image is not in the original point  after excute crop. So we need to pan.
    ciImage = [ciImage imageByApplyingTransform:CGAffineTransformMakeTranslation(-_cropX, -_cropY)];
    
    static CIContext *ciContext = nil;
    if (ciContext == nil) {
        //        NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
        //        [options setObject:[NSNull null] forKey:kCIContextWorkingColorSpace];
        //        [options setObject:@0            forKey:kCIContextUseSoftwareRenderer];
        EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
        ciContext = [CIContext contextWithEAGLContext:eaglContext options:nil];
    }
    [ciContext render:ciImage toCVPixelBuffer:pixbuffer];
    //    [ciContext render:ciImage toCVPixelBuffer:pixbuffer bounds:cropRect colorSpace:nil];
    
    CMSampleTimingInfo sampleTime = {
        .duration               = CMSampleBufferGetDuration(buffer),
        .presentationTimeStamp  = CMSampleBufferGetPresentationTimeStamp(buffer),
        .decodeTimeStamp        = CMSampleBufferGetDecodeTimeStamp(buffer)
    };
    
    if (videoInfo == NULL) {
        status = CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixbuffer, &videoInfo);
        if (status != 0) NSLog(@"Crop CMVideoFormatDescriptionCreateForImageBuffer error %d",(int)status);
    }
    
    CMSampleBufferRef cropBuffer;
    status = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, pixbuffer, true, NULL, NULL, videoInfo, &sampleTime, &cropBuffer);
    if (status != 0) NSLog(@"Crop CMSampleBufferCreateForImageBuffer error %d",(int)status);
    
    return cropBuffer;
}

@end
