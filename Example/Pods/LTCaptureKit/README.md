# LTCaptureKit

#### 项目介绍
音视频采集：基于AVFoundation等库实现


#### 安装教程

此为私有库：

1.Podfile最上面添加： source 'https://gitee.com/ppz_bj/LTCaptureKit.git'

2.PodFile添加：  pod 'LTCaptureKit',:git => 'https://gitee.com/ppz_bj/LTCaptureKit.git'

#### 基本使用

1.LTVideoCapture
    LTVideoCapture *capture = [LTVideoCapture alloc] init];
    [self.view addSubview:capture.previewLayer];

    LTVideoDataOutput *output = [[LTVideoDataOutput alloc]init]; //帧数据获取
    [capture addOutput: output];
    [capture start];
2.LTImageCaptureController
     1.该controller不带功能UI，
         可以通过继承自该controller实现功能UI并调用提供的方法（takePhoto等）
         或者实现一个实现了XDJCustomCameraViewDelegate代理方法的View,然后通过initWithControlView方法 实现
 
     2.该controller 需要presentViewController
     
     3.该controller 实现的方法有1)拍照
                         2)切换闪光灯模式
                         3)开关闪光灯
                         4)从系统相册选择图片(支持gif)
                         5)返回
   

#### 版本说明
 
 v0.0.1:
 
 1.根据AVCaptureSession特性，输入设备基本固定，前置摄像头 和 后置摄像头，所以切换就行。但输出不固定而且实现很多不一样，所以LTVideoCapture 这里不封装 输出，具体用的时候添加一个就行。
 2.所有capture都应该基于LTVideoCapture上实现。
 
 3.LTImageCaptureController 专门用于拍照
 
 4.陆续会添加 用于录像，音频，编解码等更多功能
 

v0.0.2:

LTVideoCapture：
增加功能:
1.可以通过cameraDevice属性，对硬件控制

LTImageCaptureController：
增加功能：
1.手动聚焦和自动聚焦
通过focusPointEnable属性（是否开启聚焦）
focusAtPoint方法，用于继承，一般不用调用。


v0.0.4:
加入writer 文件写入，可定制写入格式，码率帧率等。

v0.0.5:
加入简单的压缩类
LTVideoCompress
