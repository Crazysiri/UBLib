//
//  UIViewController+iconAndTip.h
//  LenzTechCategories
//
//  Created by Zero on 2018/11/19.
//  Copyright © 2018年 Zero. All rights reserved.
//

/**
 *  提示的显示和关闭分类
 */
#import <UIKit/UIKit.h>

@interface UIViewController (iconAndTip)
/**
 *  显示提示
 *
 *  top = 200,icon = nil的情况
 *
 *  @param tip 要显示的提示
 *
 */
- (void)showTip:(NSString *)tip;
- (void)showAttributedTip:(NSAttributedString *)tip;

/**
 *  显示提示
 *
 *  @param tip 要显示的提示
 *
 *  @param top 距离superview顶的距离
 *
 *  @param icon 提示图片(可以为nil)
 */
- (void)showTip:(NSString *)tip top:(CGFloat)top icon:(UIImage *)icon;

/**
 *  关闭提示
 */
- (void)hideTip;
@end
