//
//  MBVideoCapture.m
//  CameraKit
//
//  Created by Zero on 2018/10/10.
//  Copyright © 2018年 Zero. All rights reserved.
//

#import "LTVideoCapture.h"

#if __has_include("LTMotion.h")
#define MB_SUPPORT_MOTION 1
#import "LTMotion.h"
#else
#define MB_SUPPORT_MOTION 0
#endif

@interface LTVideoCapture ()
{
    BOOL _isUsingFrontFacingCamera;
}

//AVFoundation queue
@property (nonatomic) dispatch_queue_t sessionQueue;

/**
 AVCaptureSession执行输入和输出设备之间的数据传递
 */
@property (strong, nonatomic) AVCaptureSession *session;

/**
 *  输入设备
 */
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;


/**
 *  记录开始的缩放比例
 */
@property(nonatomic,assign)CGFloat beginGestureScale;



#if MB_SUPPORT_MOTION

@property (nonatomic, strong) LTMotion *motion;
@property(nonatomic, assign) UIDeviceOrientation deviceOrientation;

#endif

//startMonitoringSubjectAreaChanged 设置的View
@property (nonatomic, weak) UIView *subjectAreaChangeInView;

@end


@implementation LTVideoCapture


- (void)dealloc {
    if (_session) {
        [_session stopRunning];
    }
    _session = nil;
    
    [self endMonitoringSubjectAreaChanged];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _isUsingFrontFacingCamera = NO;
        
        self.effectiveScale = self.beginGestureScale = 1.0f;
        
        [self setupAVCapture];
        
    }
    return self;
}

- (void)addOutput:(AVCaptureOutput *)output {
    __weak typeof(self) weakself = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([weakself.session canAddOutput:output]) {
            [weakself.session addOutput:output];
        }
    });
    
    //
    //    for (AVCaptureVideoDataOutput* output in self.session.outputs) {
    //        for (AVCaptureConnection * av in output.connections) {
    //            av.videoOrientation = UIDeviceOrientationPortrait;
    //        }
    //    }
}

- (void)removeOutput:(AVCaptureOutput *)output {
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakself.session removeOutput:output];
    });
}

- (void)resetPinchScale {
    self.beginGestureScale = self.effectiveScale;
}

- (void)setupAVCapture {
    self.session = [[AVCaptureSession alloc]init];
    
    NSError *error;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //更改这个设置的时候必须先锁定设备，修改完后再订阅，否则崩溃
    [device lockForConfiguration:nil];
    
    //设置闪光灯为自动
    if ([device hasFlash])
    {
        [device setFlashMode:AVCaptureFlashModeAuto];
    }
    
    [device unlockForConfiguration];
    
    self.videoInput = [[AVCaptureDeviceInput alloc]initWithDevice:device error:&error];
    
    if (error) {
        NSLog(@"%@",error);
    }
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    
    
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
}

- (void)start {
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!weakself.session.isRunning) {
            [weakself.session  startRunning];
        }
    });
    
}


- (void)stop {
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (weakself.session.isRunning) {
            [weakself.session stopRunning];
        }
    });
}


#pragma mark 相机一般方法

- (void)setUsingFrontFace:(BOOL)usingFrontFace {
    if (usingFrontFace != _isUsingFrontFacingCamera)
        [self switchCamera];
}

- (BOOL)usingFrontFace {
    return _isUsingFrontFacingCamera;
}

//切换镜头
- (void)switchCamera {
    
    NSError *error;
    AVCaptureDevice *videoDevice_ = [self inactiveCamera];
    AVCaptureDeviceInput *videoInput_ = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice_ error:&error];
    self.videoInput = [self switchCamera:self.session old:_videoInput new:videoInput_];
//    if ([self.cameraDevice supportsAVCaptureSessionPreset:AVCaptureSessionPreset3840x2160]) {
//        [self setPreset:AVCaptureSessionPreset3840x2160];
//    } else if ([self.cameraDevice supportsAVCaptureSessionPreset:AVCaptureSessionPreset1920x1080]) {
//        [self setPreset:AVCaptureSessionPreset1920x1080];
//    } else if ([self.cameraDevice supportsAVCaptureSessionPreset:AVCaptureSessionPreset1280x720]) {
//        [self setPreset:AVCaptureSessionPreset1280x720];
//    }
    _isUsingFrontFacingCamera = !_isUsingFrontFacingCamera;
}

#pragma mark - -转换摄像头
- (AVCaptureDeviceInput *)switchCamera:(AVCaptureSession *)session old:(AVCaptureDeviceInput *)oldinput new:(AVCaptureDeviceInput *)newinput {
    [session beginConfiguration];
    [session removeInput:oldinput];
    if ([session canAddInput:newinput]) {
        [session addInput:newinput];
        [session commitConfiguration];
        return newinput;
    } else {
        [session addInput:oldinput];
        [session commitConfiguration];
        return oldinput;
    }
}


- (AVCaptureDevice *)inactiveCamera {
    AVCaptureDevice *device = nil;
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1) {
        if (self.videoInput.device.position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

#pragma mark - -输入设备
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}


- (XDCameraFlashMode)handleSwitchFlash:(BOOL)isOpen {
    
    XDCameraFlashMode mode = XDCameraFlashModeNotSupport;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //修改前必须先锁定
    [device lockForConfiguration:nil];
    //必须判定是否有闪光灯，否则如果没有闪光灯会崩溃
    if ([device hasFlash]) {
        
        if (isOpen) {
            device.flashMode = AVCaptureFlashModeOn;
            mode = XDCameraFlashModeOn;
            
        }
        else {
            device.flashMode = AVCaptureFlashModeOff;
            mode = XDCameraFlashModeOff;
        }
        
    } else {
        mode = XDCameraFlashModeNotSupport;
        NSLog(@"设备不支持闪光灯");
    }
    [device unlockForConfiguration];
    
    _mode = mode;
    
    return mode;
}



- (void)setFlashMode:(XDCameraFlashMode)mode {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    [device lockForConfiguration:nil];
    if ([device hasFlash]) {
        switch (mode) {
            case XDCameraFlashModeOn:
                [device setFlashMode:AVCaptureFlashModeOn];
                break;
            case XDCameraFlashModeOff:
                [device setFlashMode:AVCaptureFlashModeOff];
                break;
            case XDCameraFlashModeAuto:
                [device setFlashMode:AVCaptureFlashModeAuto];
                break;
            default:
                break;
        }
        _mode = mode;
    }
    
    [device unlockForConfiguration];
}//设置mode

- (XDCameraFlashMode)flash {
    
    XDCameraFlashMode mode = XDCameraFlashModeNotSupport;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //修改前必须先锁定
    [device lockForConfiguration:nil];
    //必须判定是否有闪光灯，否则如果没有闪光灯会崩溃
    if ([device hasFlash]) {
        
        if (device.flashMode == AVCaptureFlashModeOff) {
            device.flashMode = AVCaptureFlashModeOn;
            mode = XDCameraFlashModeOn;
            
        } else if (device.flashMode == AVCaptureFlashModeOn) {
            device.flashMode = AVCaptureFlashModeAuto;
            mode = XDCameraFlashModeAuto;
        } else if (device.flashMode == AVCaptureFlashModeAuto) {
            device.flashMode = AVCaptureFlashModeOff;
            mode = XDCameraFlashModeOff;
        }
        
    } else {
        mode = XDCameraFlashModeNotSupport;
        NSLog(@"设备不支持闪光灯");
    }
    [device unlockForConfiguration];
    
    return mode;
}


- (XDCameraFlashMode)switchFlash {
    
    XDCameraFlashMode mode = XDCameraFlashModeNotSupport;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //修改前必须先锁定
    [device lockForConfiguration:nil];
    //必须判定是否有闪光灯，否则如果没有闪光灯会崩溃
    if ([device hasFlash]) {
        
        if (device.torchMode == AVCaptureTorchModeOff || device.torchMode == AVCaptureFlashModeAuto) {
            device.torchMode = AVCaptureTorchModeOn;
            mode = XDCameraFlashModeOn;
        } else {
            device.torchMode = AVCaptureTorchModeOff;
            mode = XDCameraFlashModeOff;
        }
    } else {
        mode = XDCameraFlashModeNotSupport;
        NSLog(@"设备不支持闪光灯");
    }
    [device unlockForConfiguration];
    
    return mode;
}

- (void)updateFps:(NSInteger) fps{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *vDevice in videoDevices) {
        float maxRate = [(AVFrameRateRange *)[vDevice.activeFormat.videoSupportedFrameRateRanges objectAtIndex:0] maxFrameRate];
        float minRate = [(AVFrameRateRange *)[vDevice.activeFormat.videoSupportedFrameRateRanges objectAtIndex:0] minFrameRate];
        if (maxRate >= fps && fps >= minRate) {
            if ([vDevice lockForConfiguration:NULL]) {
                vDevice.activeVideoMinFrameDuration = CMTimeMake(10, (int)(fps * 10));
                vDevice.activeVideoMaxFrameDuration = vDevice.activeVideoMinFrameDuration;
                [vDevice unlockForConfiguration];
            }
        }
    }
}

//设置属性 captureDevice lock 和 unlock 之间设置
-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange{
    AVCaptureDevice *captureDevice = self.cameraDevice;
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

- (void)focusAtPoint:(CGPoint)point view:(UIView *)inView {
    CGSize size = inView.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    
    __weak typeof(self) weakself = self;
    
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([weakself.cameraDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [weakself.cameraDevice setFocusPointOfInterest:focusPoint];
            [weakself.cameraDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
    }];
}

//缩放手势 用于调整焦距
- (void)pinch:(UIPinchGestureRecognizer *)recognizer output:(AVCaptureOutput *)output {
    
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:recognizer.view];
        CGPoint convertedLocation = [self.previewLayer convertPoint:location fromLayer:self.previewLayer.superlayer];
        if ( ! [self.previewLayer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if ( allTouchesAreOnThePreviewLayer ) {
        
        
        self.effectiveScale = self.beginGestureScale * recognizer.scale;
        if (self.effectiveScale < 1.0){
            self.effectiveScale = 1.0;
        }
        
        NSLog(@"%f-------------->%f------------recognizerScale%f",self.effectiveScale,self.beginGestureScale,recognizer.scale);
        
        CGFloat maxScaleAndCropFactor = [[output connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
        
        NSLog(@"%f",maxScaleAndCropFactor);
        if (self.effectiveScale > maxScaleAndCropFactor)
            self.effectiveScale = maxScaleAndCropFactor;
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:.025];
        [self.previewLayer setAffineTransform:CGAffineTransformMakeScale(self.effectiveScale, self.effectiveScale)];
        [CATransaction commit];
        
    }
    
}

- (void)setPreset:(AVCaptureSessionPreset)preset {
    if ([self.session canSetSessionPreset:preset]) {
        self.session.sessionPreset = preset;
    }
}

- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
}

- (AVCaptureVideoOrientation)avOrientation {
    
#if MB_SUPPORT_MOTION
    if (self.enableMotion) {
        return [self avOrientationForDeviceOrientation:self.deviceOrientation];
    } else {
        UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
        return [self avOrientationForDeviceOrientation:curDeviceOrientation];
    }
#else
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    return [self avOrientationForDeviceOrientation:curDeviceOrientation];
    
#endif
    
}

- (AVCaptureDevice *)cameraDevice {
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

#pragma mark - motion

#if MB_SUPPORT_MOTION


- (void)setEnableMotion:(BOOL)enableMotion {
    
    _enableMotion = enableMotion;
    
    __weak typeof(self) weakself = self;
    
    self.motion.motionDetected = ^(CMDeviceMotion *motion) {
        //判断屏幕方向
        double x = motion.gravity.x;
        double y = motion.gravity.y;
        if (fabs(y) >= fabs(x)){
            if (y >= 0){
                weakself.deviceOrientation = UIDeviceOrientationPortraitUpsideDown;
            }else{
                weakself.deviceOrientation = UIDeviceOrientationPortrait;
            }
        }else{
            if (x >= 0){
                weakself.deviceOrientation = UIDeviceOrientationLandscapeRight;
            }else{
                weakself.deviceOrientation = UIDeviceOrientationLandscapeLeft;
            }
        }
        //外部需要检测移动
        if (weakself.motionDetected) {
            weakself.motionDetected(motion);
        }
    };
    
    self.motion.enableMotion = enableMotion;
    
    
}


- (void)setEnableAccelerometer:(BOOL)enableAccelerometer {
    
    _enableAccelerometer = enableAccelerometer;
    
    self.motion.accelerometerDetected = self.accelerometerDetected;
    
    self.motion.enableAccelerometer = enableAccelerometer;
    
}

- (void)setEnableGyro:(BOOL)enableGyro {
    
    _enableGyro = enableGyro;
    
    self.motion.gyroDetected = self.gyroDetected;
    
    self.motion.enableGyro = enableGyro;
}

- (LTMotion *)motion {
    if (!_motion) {
        _motion = [[LTMotion alloc] init];
    }
    return _motion;
}

#endif


#pragma mark - subject area change

- (void)startMonitoringSubjectAreaChanged:(UIView *)inView {
    
    self.subjectAreaChangeInView = inView;
    
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        captureDevice.subjectAreaChangeMonitoringEnabled=YES;
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.cameraDevice];
}


- (void)subjectAreaDidChange:(NSNotification *)notification {
    //先进行判断是否支持控制对焦
    if (self.cameraDevice.isFocusPointOfInterestSupported && [self.cameraDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        [self focusAtPoint:self.subjectAreaChangeInView.center view:self.subjectAreaChangeInView];
    }
}

- (void)endMonitoringSubjectAreaChanged {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:nil];
}


@end
