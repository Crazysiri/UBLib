//
//  LenzImageBrowser
//  MannerBar
//
//  Created by qiuyoubo on 2018-12-25.
//  Copyright (c) 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LenzImageBrowserSource.h"

@interface LenzImageBrowser : UIViewController

///是否开启可删除模式 默认YES
@property (nonatomic,assign) BOOL enableDelete;

@property (nonatomic,assign) NSInteger selectedIndex;

- (id)initWithSource:(LenzImageBrowserSource *)source;

/*
 一般用于 追加数据或者重设数据
 1.调用LenzImageBrowserSource appendObjects 或者 setObjects
 2.reload
 */
- (void)reload;


/**
 删除结束回调 block
 items:@[
  @{
    @"index":@(1),
    @"object":id<LenzImageSourceObject> 对应的LenzImageBrowserSource 传入的资源
   }
 ]
 */
@property (nonatomic, strong) void (^deleteCompletionBlock)(NSArray *items);


#pragma mark - For UI
/**
 下面两个方法用来 设置左右按钮：
 1.这两个方法的按钮不设置是没有的
 2.setNavigationLeftButton 默认有返回方法，但是可以移除掉
 3.setNavigationRightButton 默认没有方法，需要外部设置方法
 */
- (void)setNavigationLeftButton:(void(^)(UIButton *button))block needNew:(BOOL)needNew;
- (void)setNavigationRightButton:(void(^)(UIButton *button))block needNew:(BOOL)needNew;

//标题view 用来显示 1/20 的
@property (nonatomic, strong,readonly) UILabel *navigationTitleLabel;




#pragma mark - For resource

///图片资源bundle 默认LenzAlbumBundle
/*
 图片资源需要：
 videocard_play ：LenzImageBrowserCell->videoPlayBtn
 */
@property (nonatomic, strong) NSBundle *resourceBundle;

@end
