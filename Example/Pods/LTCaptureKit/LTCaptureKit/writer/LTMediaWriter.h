//
//  LTMediaWriter.h
//  LenzBusiness
//
//  Created by Zero on 2019/2/13.
//  Copyright © 2019 LenzTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface LTMediaWriterVideoSettings : NSObject

///视频大小： 默认 (640,360)
/*
 一般：
 低清(252*288)
 标清(480*340)
 高清(640*480)
 超清(960*540)
 超高清(1280*720)
 */
@property (nonatomic,assign) CGSize videoSize;

///每像素比特（算码率，例如：1280 * 720 * bitsPerPixel） 默认 6 （iPhnoe6s 15左右 3560码率）
@property (nonatomic,assign) CGFloat bitsPerPixel;

///帧率 默认 25
@property (nonatomic,assign) NSInteger frameRate;

///旋转角度 默认 M_PI / 2.0
@property (nonatomic,assign) CGFloat rotate;

//默认：AVVideoProfileLevelH264MainAutoLevel
@property (copy,nonatomic) NSString *AVVideoProfileLevelH264;

- (NSDictionary *)settings;

@end





@interface LTMediaWriterAudioSettings : NSObject

///码率 单声道 默认 28000
@property (nonatomic,assign) CGFloat bitratePerChannel;

///几个声道 默认 1
@property (nonatomic,assign) NSInteger numberOfChannels;

///采样率 默认 22050
@property (nonatomic,assign) NSInteger sampleRate;


- (NSDictionary *)settings;
@end





@interface LTMediaWriter : NSObject


///保存成功回调 finishWriting 方法之后会调用该方法
@property (nonatomic,copy) void (^writingCompletion)(void);



//是否存储到相册
/*
 finishWriting之前调用即可生效
 默认 为 YES
 */
@property (nonatomic,assign) BOOL saveToAlbum;


///保存到相册成功 saveToAlbum == YES的时候
@property (nonatomic,copy) void (^saveToAlbumCompletion)(NSURL *videoURL, NSError *error);


/*
 1
 */
- (instancetype)initWithOutputURL:(NSURL *)outputURL;




/*
 2
 */
///启用 音频 ，不调用默认 不启用
- (BOOL)enableAudioWithSettings:(LTMediaWriterAudioSettings *)audioSettings;

///启用 视频 ，不调用默认 不启用
- (BOOL)enableVideoWithSettings:(LTMediaWriterVideoSettings *)videoSettings;

/*
 3
 */
///写入数据
- (void)writeSampleBuffer:(CMSampleBufferRef)sampleBuffer mediaType:(int)type; // 1 video 2 audio

/*
 4
 */
///停止写入
- (BOOL)finishWriting;



#pragma mark - optional

///设置元数据
/*
 默认元数据：
 AVMetadataCommonKeyModel，
 AVMetadataCommonKeySoftware，
 AVMetadataQuickTimeMetadataKeyCreationDate
 */
- (void)setMetadata:(NSArray <AVMetadataItem *> *)meta;

@end



/*
 设置shouldOptimizeForNetworkUse可以在边下边播的时候快速播放。
 参数参考：
 视频采集帧率：25
 视频编码码率：150000
 视频编码器类型：AVC/h.264编码
 视频采集编码的分辨率：低清(252*288)标清(480*340)高清(640*480)超清(960*540)超高清(1280*720)
 摄像头收视响应变焦功能
 编码类型：硬编码，软编码
 音频采集帧率：2048
 音频编码码率：64000
 音频采样率：44100
 采集编码声道：单声道，双声道
 音频编码类型：AAC/GIPS
 
 
 
 6s设备的系统录制参数：
 码率：3560kb/s
 分辨率：640*360
 帧率：30fps
 图像格式：yuv420p
 */



/*
 avc编码分为三等：
 Baseline，Main，High
 
 Baseline（最低Profile）级别支持I/P 帧，只支持无交错（Progressive）和CAVLC，一般用于低阶或需要额外容错的应用，比如视频通话、手机视频等；
 Main（主要Profile）级别提供I/P/B 帧，支持无交错（Progressive）和交错（Interlaced），同样提供对于CAVLC 和CABAC 的支持，用于主流消费类电子产品规格如低解码（相对而言）的mp4、便携的视频播放器、PSP和Ipod等；
 High（高端Profile，也叫FRExt）级别在Main的基础上增加了8x8 内部预测、自定义量化、无损视频编码和更多的YUV 格式（如4：4：4）用于广播及视频碟片存储（蓝光影片），高清电视的应用。
 
 
 一般来说，Main比baseline在同等画质下要求码率更低。
 
 */
