//
//  XDJCustomCameraController.h
//  CameraKit
//
//  Created by Zero on 2018/10/10.
//  Copyright © 2018年 Zero. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LTCustomCameraViewDelegate.h"

#import "LTVideoCapture.h"


/*
 说明：
 1.该controller不带功能UI，
 可以通过继承自该controller实现功能UI并调用提供的方法（takePhoto等）
 或者实现一个实现了XDJCustomCameraViewDelegate代理方法的View,然后通过initWithControlView方法 实现
 
 2.该controller 需要presentViewController
 
 3.该controller 实现的方法有1)拍照
 2)切换闪光灯模式
 3)开关闪光灯
 4)从系统相册选择图片(支持gif)
 5)返回
 
 */

@interface LTImageCaptureController : UIViewController

@property (nonatomic, strong,readonly) LTVideoCapture *capture;

@property (assign, nonatomic) BOOL scaleGestureEnable; //手势放大缩小镜头，默认是no,


/**
 支持手动和自动聚焦
 */
@property (nonatomic, assign) BOOL focusPointEnable;

/**
 手动聚焦点击事件
 
 @param point 手触摸屏幕的位置
 */
- (void)focusAtPoint:(CGPoint)point;
//外边修改点击范围
- (void)tapScreen:(UITapGestureRecognizer *)gesture;


@property (assign, nonatomic) BOOL saveToAlbum; //存到本地手机相册
@property (copy ,nonatomic) void(^completionBlock)(UIImage *image); //拍照 或者 系统相册选择图片后的回调

- (id)initWithControlView:(UIView <LTCustomCameraViewDelegate> *)view;


- (void)takePhoto; //拍照

#pragma mark 拍照 life cycle 用于继承
/*
 ->获取原始数据
 ->handleImage(二次处理)
 ->canFinish(是否能结束，YES调用finish，NO不调用)
 ->finish
 ->(completionBlock)
 */
- (UIImage *)handleImage:(UIImage *)image;
- (BOOL)canFinish:(UIImage *)image;
- (void)finish:(UIImage *)image;




- (void)selectFromAlbum; //从系统相册选择照片

- (void)back; //返回 dismiss



#pragma mark - 生命周期的 block

@property (nonatomic,copy) void (^_viewDidLoad)(void);
@property (nonatomic,copy) void (^_viewWillAppear)(BOOL animated);
@property (nonatomic,copy) void (^_viewDidlAppear)(BOOL animated);
@property (nonatomic,copy) void (^_viewWillDisappear)(BOOL animated);
@property (nonatomic,copy) void (^_viewDidDisappear)(BOOL animated);


#pragma mark - for output

//剪裁参数 上下左右
@property (nonatomic,assign) UIEdgeInsets cropInsets;

@end
