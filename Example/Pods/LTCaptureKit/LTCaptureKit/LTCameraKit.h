//
//  MBCameraKit.h
//  CameraKit
//
//  Created by Zero on 2018/10/10.
//  Copyright © 2018年 Zero. All rights reserved.
//



#ifndef LTCameraKit_h
#define LTCameraKit_h

#import "LTCameraKitDefines.h"

#import "LTVideoCapture.h"
#import "LTVideoDataOutput.h"

#import "LTImageCaptureController.h"

#import "UIImage+capture.h"

#import "LTMotion.h"

#endif /* MBCameraKit_h */


/*
 
 v0.0.1:
 
 1.根据AVCaptureSession特性，输入设备基本固定，前置摄像头 和 后置摄像头，所以切换就行。但输出不固定而且实现很多不一样，所以MBVideoCapture 这里不封装 输出，具体用的时候添加一个就行。
 2.所有capture都应该基于MBVideoCapture上实现。
 
 3.LTImageCaptureController 专门用于拍照
 
 4.陆续会添加 用于录像，音频，编解码等更多功能
 */

/*
 
 v0.0.2:
 
 LTVideoCapture：
 增加功能:
 1.可以通过cameraDevice属性，对硬件控制
 
 LTImageCaptureController：
 增加功能：
 1.手动聚焦和自动聚焦
    通过focusPointEnable属性（是否开启聚焦）
    focusAtPoint方法，用于继承，一般不用调用。
 
 v0.0.3:
 LTVideoCapture：
 增加功能：
 1.闪光灯开关（只有两种状态）
 
 v0.0.4:
 writer目录
 增加功能：从视频流，音频流 写文件自定义。
 1.LTVideoCaptureAndWriteController：无UI 提供基础功能的controller
    1）initWithOutputURL ：用本地路径的url初始化
    2）startVideoRecorder 开始录制（写入文件）
    3）stopVideoRecorder :停止录制（完成写入）
 
 2.LTMediaWriter：音频流视频流写入类
    1）initWithOutputURL 用本地路径的url初始化
    2）enableAudioWithSettings/enableVideoWithSettings 启用音/视频
    3）writeSampleBuffer 写入数据
    4）finishWriting 结束写入
 3.LTVideoPlayer 基于 AVPlayer 的简单 视频 播放器
 */
