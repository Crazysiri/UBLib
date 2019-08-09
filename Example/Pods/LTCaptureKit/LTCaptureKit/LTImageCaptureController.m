//
//  XDJCustomCameraController.m
//  CameraKit
//
//  Created by Zero on 2018/10/10.
//  Copyright © 2018年 Zero. All rights reserved.
//

#define kMainScreenWidth [UIScreen mainScreen].bounds.size.width
#define kMainScreenHeight  [UIScreen mainScreen].bounds.size.height

#define dispatch_main_async_safe_camera(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

#import "LTImageCaptureController.h"

#import <AVFoundation/AVFoundation.h>

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>


#if __has_include("UIImage+GIF.h")
#define LT_CAPTURE_SUPPORT_GIF 1
#import "UIImage+GIF.h"
#elif __has_include(<UIImage+GIF.h>)
#define LT_CAPTURE_SUPPORT_GIF 1
#import <UIImage+GIF.h>
#else
#define LT_CAPTURE_SUPPORT_GIF 0
#endif


#import <MobileCoreServices/MobileCoreServices.h>

#import "UIImage+capture.h"

@interface LTImageCaptureController () <UIGestureRecognizerDelegate
,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
}
@property (strong, nonatomic) UIView <LTCustomCameraViewDelegate> *customView;

@property (weak, nonatomic) UIView *videoView;

/**
 *  照片输出流
 */
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;


#pragma mark - ipad
@property (nonatomic, strong) UIPopoverController *popOver;

@end

@implementation LTImageCaptureController

- (void)dealloc {
    [self.customView removeFromSuperview];
    self.customView = nil;
    [self.capture stop];
    self.capture.enableMotion = NO;
}


- (id)initWithControlView:(UIView <LTCustomCameraViewDelegate> *)view {
    self = [super init];
    if (self) {
        self.customView = view;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.capture start];
    
    if (self._viewWillAppear) {
        self._viewWillAppear(animated);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.capture stop];
    
    if (self._viewWillDisappear) {
        self._viewWillDisappear(animated);
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self._viewDidDisappear) {
        self._viewDidDisappear(animated);
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    //    [self setNavigationBarHidden:YES];
    
    UIView *videoView = [[UIView alloc]init];
    self.videoView = videoView;
    [self.view addSubview:videoView];
    self.view.autoresizesSubviews = YES;
    videoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    videoView.frame = self.view.bounds;
    //    [videoView layoutToSuperViewBounds];
    
    [self setupCustomView];
    
    _capture = [[LTVideoCapture alloc]init];
    
    [self setupAVCapture];
    
    if (self._viewDidLoad) {
        self._viewDidLoad();
    }
    // Do any additional setup after loading the view.
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    
}

- (void)setupCustomView {
    if (!self.customView) {
        return;
    }
    
    [self.view addSubview:self.customView];
    self.customView.frame = self.view.bounds;
    __weak typeof(self) weakSelf = self;
    [self.customView setTakePhotoBlock:^{
        [weakSelf takePhoto];
        
    }];
    
    [self.customView setFlashSwitchBlock:^XDCameraFlashMode{
        return  [weakSelf.capture flash];
    }];
    
    [self.customView setBackBlock:^{
        [weakSelf back];
    }];
    
    [self.customView setFlashSwitchBlock:^XDCameraFlashMode{
        return [weakSelf.capture switchFlash];
    }];
    
    [self.customView setSelectFromAlbumBlock:^{
        [weakSelf selectFromAlbum];
    }];
}



- (void)setupAVCapture {
    
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc]init];
    
    //输出设备 JPEG
    //默认值
    //    NSDictionary *outputSettings = [[NSDictionary alloc]initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    NSDictionary *outputSettings = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey, nil];
    
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    
    [self.capture addOutput:self.stillImageOutput];
    
    
    
    self.capture.previewLayer.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight);
    
    [self.videoView.layer addSublayer:self.capture.previewLayer];
}


#pragma mark - 放大缩小手势

- (void)setupGesture {
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinch.delegate = self;
    [self.view addGestureRecognizer:pinch];
}

//缩放手势 用于调整焦距
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer{
    [self.capture pinch:recognizer output:self.stillImageOutput];
}

#pragma mark gestureRecognizer delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        [self.capture resetPinchScale];
    }
    return YES;
}

#pragma mark - 聚焦

- (void)setFocusPointGesture {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)tapScreen:(UITapGestureRecognizer *)gesture{
    CGPoint point = [gesture locationInView:gesture.view];
    [self focusAtPoint:point];
}

- (void)focusAtPoint:(CGPoint)point {
    CGSize size = self.view.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([self.capture.cameraDevice lockForConfiguration:&error]) {
        if ([self.capture.cameraDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.capture.cameraDevice setFocusPointOfInterest:focusPoint];
            [self.capture.cameraDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        [self.capture.cameraDevice unlockForConfiguration];
    }
}

#pragma mark 拍照 life cycle

- (UIImage *)handleImage:(UIImage *)image {
    return image;
}

- (BOOL)canFinish:(UIImage *)image {
    return YES;
}

- (void)finish:(UIImage *)image {
    
    if (self.completionBlock) {
        
        self.completionBlock(image);
    }
}



#pragma mark 相机一般方法


- (void)takePhoto {
    
    AVCaptureConnection *stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    AVCaptureVideoOrientation avcaptureOrientation = [self.capture avOrientation];
    [stillImageConnection setVideoOrientation:avcaptureOrientation];
    [stillImageConnection setVideoScaleAndCropFactor:self.capture.effectiveScale];
    __weak typeof(self) weakSelf = self;
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        if (!weakSelf) {
            return;
        }
        
        if (!error) {
            
            CMTime time = CMSampleBufferGetDecodeTimeStamp(imageDataSampleBuffer);
            if (time.timescale <= 0) {
            }
            
            
            if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, weakSelf.cropInsets)) {
                //top left bottom right
                imageDataSampleBuffer = [UIImage cropSampleBufferBySoftware:imageDataSampleBuffer insets:weakSelf.cropInsets];
            }
            
            //            NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            //外部可能要处理一下
            UIImage *image = [UIImage imageFromCMSampleBufferRef_RGB:imageDataSampleBuffer orientation:avcaptureOrientation];
            image = [weakSelf handleImage:image];
            if (![weakSelf canFinish:image]) {
                return;
            }
            if (weakSelf.saveToAlbum) {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    //通过URL将图片保存到相册
                    [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                    
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    
                }];
            }
            
            [weakSelf finish:image];
            
        }else{
            //相机初始化错误
            
        }
        
    }];
    
}


- (void)selectFromAlbum {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    if (@available(iOS 11.0, *)) {
        UIScrollView.appearance.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    } else {
        picker.automaticallyAdjustsScrollViewInsets = YES;
    }
    picker.modalPresentationStyle = UIModalPresentationCurrentContext;
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = @[(NSString *)kUTTypeImage];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIPopoverController *poVer = [[UIPopoverController alloc] initWithContentViewController:picker];
        self.popOver = poVer;
        [self.popOver presentPopoverFromRect:CGRectMake(0, 0, self.view.center.x , self.view.center.y) inView:self.view  permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
        [self.popOver setPopoverContentSize:CGSizeMake(kMainScreenWidth, kMainScreenWidth) animated:YES];
    }else{
        [self presentViewController:picker animated:YES completion:nil];
    }
    
}

- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __weak typeof(self) weakSelf = self;
    if (picker.sourceType != UIImagePickerControllerSourceTypeCamera) {
        
        NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];
        ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
        
        void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *) = ^(ALAsset *asset) {
            
            if (asset != nil) {
                dispatch_main_async_safe_camera(^{
                    ALAssetRepresentation *rep = [asset defaultRepresentation];
                    Byte *imageBuffer = (Byte*)malloc(rep.size);
                    NSUInteger bufferSize = [rep getBytes:imageBuffer fromOffset:0.0 length:rep.size error:nil];
                    NSData *imageData = [NSData dataWithBytesNoCopy:imageBuffer length:bufferSize freeWhenDone:YES];
                    UIImage *originImage = nil;
                    if ([asset representationForUTI:(__bridge NSString *)kUTTypeGIF]) {
#if LT_CAPTURE_SUPPORT_GIF
                        originImage = [UIImage sd_animatedGIFWithData:imageData];
#endif
                    }
                    else{
                        originImage = [UIImage imageWithData:imageData];
                    }
                    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) && weakSelf.popOver) {
                        [weakSelf.popOver dismissPopoverAnimated:YES];
                    } else {
                        [picker dismissViewControllerAnimated:YES completion:nil];
                    }
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        if (weakSelf.completionBlock) {
                            weakSelf.completionBlock(originImage);
                        }
                    });
                    
                    
                });
            }
            else {
            }
        };
        
        [assetLibrary assetForURL:url
                      resultBlock:ALAssetsLibraryAssetForURLResultBlock
                     failureBlock:^(NSError *error) {
                         
                     }];
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (self.popOver) {
        [self.popOver dismissPopoverAnimated:YES];
    } else {
        //        __weak typeof(self) weakSelf = self;
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    
}


#pragma mark - setter and getter

- (void)setScaleGestureEnable:(BOOL)scaleGestureEnable {
    _scaleGestureEnable = scaleGestureEnable;
    if (scaleGestureEnable) {
        [self setupGesture];
    }
}

- (void)setFocusPointEnable:(BOOL)focusPointEnable {
    _focusPointEnable = focusPointEnable;
    if (focusPointEnable) {
        //设置手动聚焦的手势
        [self setFocusPointGesture];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
