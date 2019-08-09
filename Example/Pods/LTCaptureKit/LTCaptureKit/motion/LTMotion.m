//
//  TJLMotion.m
//  MannerBar
//
//  Created by Zero on 2018/10/12.
//  Copyright © 2018年 user. All rights reserved.
//

#import "LTMotion.h"


@interface LTMotion ()

@property(nonatomic, strong) CMMotionManager *motionManager;

@property (nonatomic, strong) NSOperationQueue *commonQueue;


@end

@implementation LTMotion


- (void)dealloc {
    [self stopMotion];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

//移动检查

- (void)setEnableMotion:(BOOL)enableMotion {
    _enableMotion = enableMotion;
    if (_enableMotion) {
        [self startMotion];
    } else {
        [self stopMotion];
    }
}

- (void)startMotion {
    self.motionManager.deviceMotionUpdateInterval = 1.0 / 4.0;
    if (!self.motionManager.deviceMotionAvailable) {
        return;
    }
    [self.motionManager startDeviceMotionUpdatesToQueue:self.commonQueue withHandler: ^(CMDeviceMotion *motion, NSError *error){
        
        [self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:NO];
    }];
    
//    [self.motionManager startDeviceMotionUpdates];
}

- (void)stopMotion {
    [self.motionManager stopDeviceMotionUpdates];
}

- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion{
    if (self.motionDetected) {
        self.motionDetected(deviceMotion);
    }
}


//加速检测

- (void)setEnableAccelerometer:(BOOL)enableAccelerometer {
    _enableAccelerometer = enableAccelerometer;
    if (enableAccelerometer) {
        [self startAccelerometer];
    } else {
        [self stopAccelerometer];
    }
}

- (void)startAccelerometer {
    __weak typeof(self) weakself = self;
    
    if (!self.motionManager.accelerometerAvailable) return;
    
    //设置CMMotionManager的加速度数据更新频率为0.1秒
    self.motionManager.accelerometerUpdateInterval = 1 / 2;
    //使用代码块开始获取加速度数据
    [self.motionManager startAccelerometerUpdatesToQueue:self.commonQueue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        //如果发生了错误，error不为空
        if (error) {
            //停止获取加速度数据
            [weakself stopAccelerometer];
        }else{
            
            //分别获取系统在X、Y、Z轴上的加速度数据
            [self performSelectorOnMainThread:@selector(handleDeviceAccelerometer:) withObject:accelerometerData waitUntilDone:NO];
        }
    }];
}

- (void)stopAccelerometer {
    [self.motionManager stopAccelerometerUpdates];
}

- (void)handleDeviceAccelerometer:(CMAccelerometerData *)accelerometerData{
    if (self.accelerometerDetected) {
        self.accelerometerDetected(accelerometerData);
    }
}

//陀螺仪检测

- (void)setEnableGyro:(BOOL)enableGyro {
    _enableGyro = enableGyro;
    if (enableGyro) {
        [self startGyro];
    } else {
        [self stopGyro];
    }
}

- (void)startGyro {
    __weak typeof(self) weakself = self;

    if (!self.motionManager.gyroAvailable)return;
    //设置CMMOtionManager的陀螺仪数据更新频率为0.1；
    self.motionManager.gyroUpdateInterval = 1.0 / 3.0;
    //使用代码块开始获取陀螺仪数据
    [self.motionManager startGyroUpdatesToQueue:self.commonQueue withHandler:^(CMGyroData *gyroData, NSError *error) {
        // 如果发生了错误，error不为空
        if (error){
            [weakself stopGyro];
        }
        // 在主线程中更新gyroLabel的文本，显示绕各轴的转速
        [self performSelectorOnMainThread:@selector(handleGyro:) withObject:gyroData waitUntilDone:NO];
        
    }];
}
- (void)stopGyro {
    [self.motionManager stopGyroUpdates];
}

- (void)handleGyro:(CMGyroData *)gyroData{
    if (self.gyroDetected) {
        self.gyroDetected(gyroData);
    }
}



- (NSOperationQueue *)commonQueue {
    if (!_commonQueue) {
        _commonQueue = [[NSOperationQueue alloc]init];
    }
    return _commonQueue;
}

- (CMMotionManager *)motionManager {
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    return _motionManager;
}
@end
