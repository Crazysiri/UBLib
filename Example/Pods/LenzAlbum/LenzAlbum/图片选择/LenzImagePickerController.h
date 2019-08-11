//
//  PPZGridViewController.h
//  ppz_businessman
//
//  Created by ronggang wang on 2018/7/5.
//  Copyright © 2018年 paipaizhuan. All rights reserved.
//

#import "LenzImageBrowserSource.h"

#import "LenzImagePickerBottomView.h"


typedef NS_ENUM(NSInteger,LenzImagePickerFetchType) {
    LenzImagePickerFetchTypeAll = 1, //相册里所有的图片
    LenzImagePickerFetchTypeGiven, //传入的图片
};

@interface LenzImagePickerControllerConfig : NSObject

///最大选择的数量，默认 == -1:表示无限
@property (nonatomic,assign) NSInteger maxSelectedCount;

///每一横行 有几个 默认 == 4
@property (nonatomic,assign) NSInteger gridItemNumberOfColumns;

///每个格的间距 默认 == 4
@property (nonatomic,assign) CGFloat gridSpace;

///背景颜色 默认 white
@property (nonatomic, strong) UIColor *backgroundColor;

///
/*默认       无视频或照片
      你可以使用相机拍摄照片或视频
 */
@property (copy,nonatomic) NSAttributedString *noPhotoTip;

///图片资源bundle 默认LenzAlbumBundle
/*
 图片资源需要：
 question_xuanzhong ：TJLGridCollectionCell->checkImageView选中状态
 question_weixuanzhong ： TJLGridCollectionCell->checkImageView未选中状态
 */
@property (nonatomic, strong) NSBundle *resourceBundle;


+ (instancetype)defaultConfig;

@end

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

/*
 default title ： 相机胶卷
 */

@interface LenzImagePickerController : UIViewController

///底部view 的tip
@property (copy,nonatomic) NSString *bottomViewTip;
@property (copy,nonatomic) NSAttributedString *attributedBottomViewTip;


 //获取相册图片数组成功后的回调
//initWithSource 中source对应的数据源类型
@property (nonatomic, strong) void(^pickerSuccessedHanlder)(NSArray <id <LenzImageSourceObject>> *selectedAssets);

///小图点击
@property (nonatomic,copy) void (^previewClickBlock)(NSInteger index,LenzImageBrowserSource *source);

#pragma mark - initial

/*
    用配置初始化
 
    config ：配置。 可为 nil （nil的时候 默认 LenzImagePickerControllerConfig.defaultConfig）
 
    source：数据源
 */
- (id)initWithConfig:(LenzImagePickerControllerConfig *)config
              source:(LenzImageBrowserSource *)source;

/*
 用默认配置初始化（LenzImagePickerControllerConfig.defaultConfig）
 
 source：数据源
 */
- (id)initWithSource:(LenzImageBrowserSource *)source;


- (id)init UNAVAILABLE_ATTRIBUTE;

/*
 一般用于 追加数据或者重设数据
 1.调用LenzImageBrowserSource appendObjects 或者 setObjects
 2.reload
 */
- (void)reload;

#pragma mark - for UI

- (void)setNavigationRightButton:(void(^)(UIButton *button))block needNew:(BOOL)needNew;

//通过LenzImagePickerBottomView协议 可自定义 bottomView 默认的是TJLBottomEditView，强转出来即可使用
@property (strong, nonatomic) UIView <LenzImagePickerBottomView> * bottomEditView;

@end
