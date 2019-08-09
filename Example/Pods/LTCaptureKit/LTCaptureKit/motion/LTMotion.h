//
//  TJLMotion.h
//  MannerBar
//
//  Created by Zero on 2018/10/12.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>


@interface LTMotion : NSObject


//移动检查
@property (nonatomic,copy) void(^motionDetected) (CMDeviceMotion *motion);
@property (nonatomic,assign) BOOL enableMotion;


//加速检测
@property (nonatomic,copy) void(^accelerometerDetected) (CMAccelerometerData *accelerometerData);
@property (nonatomic,assign) BOOL enableAccelerometer;


//陀螺仪检测
@property (nonatomic,copy) void(^gyroDetected) (CMGyroData *gyroData);
@property (nonatomic,assign) BOOL enableGyro;


//磁场检测




@end
