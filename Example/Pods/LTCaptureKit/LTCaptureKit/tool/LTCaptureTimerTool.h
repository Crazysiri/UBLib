//
//  LTCaptureTimerTool.h
//  LenzTechCaptureKit
//
//  Created by Zero on 2019/5/17.
//  Copyright © 2019 Zero. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LTCaptureTimerTool : NSObject


//timerInterval
@property (nonatomic,assign) NSTimeInterval step;//每次调用的间隔，单位：秒 默认 1.0f

/*
 
 1.alloc init
 2.设置间隔continuesInterval
 3.设置当前数量和最大数量currentCount maxCount
 4.startTimer
 5.接收两个回调 一个 美秒调用一次 一个每次到达continuesInterval调用一次
 */
@property (nonatomic,assign) NSTimeInterval continuesInterval;//间隔 秒

@property (nonatomic,assign) NSInteger currentCount; //当前数量
@property (nonatomic,assign) NSInteger maxCount; //最大数量

@property (nonatomic, assign) BOOL isContinues_status;//是否处于连拍状态

//每次开始的时候
@property (nonatomic,copy) void (^fireWhenStart)(NSInteger cooldown);

//每一个间隔（默认1秒钟） timerInterval
@property (nonatomic,copy) void (^fireEveryStep)(NSInteger cooldown);
//每次到达间隔时
//BOOL返回 可以回调本次是否计数（例如拍照时 存储失败，这里可以返回NO，currentCount则不变）
@property (nonatomic,copy) BOOL (^fireWhenReachInterval)(NSInteger currentCount,NSInteger maxCount);


- (void)startTimer;
- (void)endTimer;

- (void)pause;
- (void)resume;

@end

NS_ASSUME_NONNULL_END
