//
//  MBImageScrollView.h
//  MannerBar
//
//  Created by liangw on 13-2-1.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 * Description : 大的scrollView里面的单张图片
 *
 */

@interface MBImageScrollView : UIScrollView<UIScrollViewDelegate>

//显示转圈圈
@property (nonatomic, weak) UIActivityIndicatorView *indicatorView;


@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) NSUInteger index;

- (void)startLoading:(BOOL)start;

- (void)updateLayout;

@end
