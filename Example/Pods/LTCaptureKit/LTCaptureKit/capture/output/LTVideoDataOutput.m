//
//  LTVideoDataOutput.m
//  ppz_businessman
//
//  Created by Zero on 2018/10/17.
//  Copyright © 2018年 paipaizhuan. All rights reserved.
//
/*
 
 kCVPixelFormatType_{长度|序列}{颜色空间}{Planar|BiPlanar}{VideoRange|FullRange}
 
 Planar: 平面；BiPlanar：双平面
 平面／双平面主要应用在yuv上,uv分开存储的为Planar，反之是BiPlanar.
 所以，kCVPixelFormatType_420YpCbCr8PlanarFullRange是420p，kCVPixelFormatType_420YpCbCr8BiPlanarFullRange是nv12.
 
 VideoRange和FullRange的区别在于数值的范围，FullRange比VideoRange大一些，颜色也更丰富一些。
 如果没有指定颜色范围，默认都是FullRange。但有一个除外：kCVPixelFormatType_420YpCbCr8Planar。因为有一个kCVPixelFormatType_420YpCbCr8PlanarFullRange定义，所以kCVPixelFormatType_420YpCbCr8Planar理论上应该是VideoRange
 https://ffmpeg.org/pipermail/ffmpeg-devel/2016-April/193420.html
 
 颜色空间对应的就是它在内存中的顺序。比如kCVPixelFormatType_32BGRA，内存中的顺序是 B G R A B G R A...。
 有一些特别的，比如kCVPixelFormatType_16BE555，这里需要用BE或LE指定字节顺序。
 
 有的颜色空间后面还带有一个数字，用于表示bit长度。
 
 */

#import "LTVideoDataOutput.h"
@interface LTVideoDataOutput () {
    AVCaptureVideoDataOutput *_output;
    dispatch_queue_t _captureQueue;
}

//kCVPixelBufferPixelFormatTypeKey等
@property (nonatomic, strong) NSDictionary<NSString *, id> *videoSettings;

@property (nonatomic, weak) id <AVCaptureVideoDataOutputSampleBufferDelegate> delegate;

@end


@implementation LTVideoDataOutput


- (id)initWithBuilder:(void(^)(LTVideoDataOutputBuilder *buidler))build {
    if (self = [super init]) {
        LTVideoDataOutputBuilder *buidler = [[LTVideoDataOutputBuilder alloc]init];
        build(buidler);
        _captureQueue = buidler.captureQueue;
        _videoSettings = buidler.videoSettings;
        _delegate = buidler.delegate;
    }
    return self;
}

- (AVCaptureVideoDataOutput *)output {
    if (_output == nil) {
        _output = [[AVCaptureVideoDataOutput alloc] init];
        [_output setSampleBufferDelegate:_delegate queue:self.captureQueue];
        _output.videoSettings = self.videoSettings;
    }
    return _output;
}

- (NSDictionary<NSString *,id> *)videoSettings {
    if (!_videoSettings) {
        /*
         [_output availableVideoCVPixelFormatTypes]:
         
        kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
        
        kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        
        kCVPixelFormatType_32BGRA
         */
        NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                                        nil];
        _videoSettings = settings;
    }
    return _videoSettings;
}

- (dispatch_queue_t)captureQueue {
    if (_captureQueue == nil) {
        _captureQueue = dispatch_queue_create("com.lt.capture.queue", DISPATCH_QUEUE_SERIAL);
    }
    return _captureQueue;
}
@end


@implementation LTVideoDataOutputBuilder
@end

