//
//  MBVideoCapture.h
//  CameraKit
//
//  Created by Zero on 2018/10/10.
//  Copyright © 2018年 Zero. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "LTCameraKitDefines.h"

#import <CoreMotion/CoreMotion.h>

typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);


/***
 类里私有变量，如果开放并且是不能修改的记得加readonly
 */

@interface LTVideoCapture : NSObject

/**
 *  预览图层
 */
@property (nonatomic, strong,readonly) AVCaptureVideoPreviewLayer* previewLayer;


/**
 设备
 */
@property (nonatomic, strong,readonly) AVCaptureDevice* cameraDevice;



#pragma mark - 初始化相关

- (void)addOutput:(AVCaptureOutput *)output; //添加输出
- (void)removeOutput:(AVCaptureOutput *)output;

#pragma mark - 启动/停止


- (void)start;
- (void)stop;


#pragma mark - 缩放

@property(nonatomic,assign)CGFloat effectiveScale; //最后的缩放比例

- (void)resetPinchScale; //设置缩放

//缩放手势 用于调整焦距
- (void)pinch:(UIPinchGestureRecognizer *)recognizer output:(AVCaptureOutput *)output;

#pragma mark - 相机方法（闪光等，后续会开放更多）

@property (nonatomic,assign) BOOL usingFrontFace;

@property (nonatomic,assign) XDCameraFlashMode mode; //设置mode

- (XDCameraFlashMode)flash;//切换模式，并返回当前模式

- (XDCameraFlashMode)switchFlash;//开关闪光灯(手电筒)

- (XDCameraFlashMode)handleSwitchFlash:(BOOL)isOpen;//闪光灯开启/关闭

- (void)setPreset:(AVCaptureSessionPreset)preset;

- (void)updateFps:(NSInteger) fps; //设置 采集 fps

//设置属性 captureDevice lock 和 unlock 之间设置
-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange;

//聚焦 点 和 在某个view上 
- (void)focusAtPoint:(CGPoint)point view:(UIView *)inView;

//根据设备方向 获取 capture方向
- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation;

//根据当前设备方向 获取 capture方向
- (AVCaptureVideoOrientation)avOrientation;

#pragma mark - motion 移动相关
//主要影响avOrientationForDeviceOrientation 的取值

//移动
@property (nonatomic,assign) BOOL enableMotion;

@property (copy,nonatomic) void (^motionDetected)(CMDeviceMotion *motion);

//加速计
@property (nonatomic,assign) BOOL enableAccelerometer;

@property (copy,nonatomic) void(^accelerometerDetected) (CMAccelerometerData *accelerometerData);

//陀螺仪
@property (nonatomic,assign) BOOL enableGyro;

@property (nonatomic,copy) void(^gyroDetected) (CMGyroData *gyroData);


#pragma mark - subject area change
/*
 //自动对象,苹果提供了对应的通知api接口,可以直接添加通知
 //注意添加区域改变捕获通知必须首先设置设备允许捕获
 inView在哪个view上
 */
- (void)startMonitoringSubjectAreaChanged:(UIView *)inView;

@end
