//
//  LTVideoDataOutput.h
//  ppz_businessman
//
//  Created by Zero on 2018/10/17.
//  Copyright © 2018年 paipaizhuan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

//构造器（构造dataout生成的，方便扩展更多参数）
@interface LTVideoDataOutputBuilder : NSObject

@property (nonatomic, strong) dispatch_queue_t captureQueue;

//kCVPixelBufferPixelFormatTypeKey等
@property (nonatomic, strong) NSDictionary<NSString *, id> *videoSettings;

@property (nonatomic, weak) id <AVCaptureVideoDataOutputSampleBufferDelegate> delegate;


@end




//output 实际就是 AVCaptureVideoDataOutput封装，有默认的 setting：yuv420输出格式 和 输出队列
@interface LTVideoDataOutput : NSObject

@property (nonatomic, strong,readonly) dispatch_queue_t captureQueue;

- (id)initWithBuilder:(void(^)(LTVideoDataOutputBuilder *buidler))build;

- (AVCaptureVideoDataOutput *)output;
@end
