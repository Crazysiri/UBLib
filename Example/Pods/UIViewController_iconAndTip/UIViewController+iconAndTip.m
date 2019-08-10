//
//  UIViewController+iconAndTip.m
//  LenzTechCategories
//
//  Created by Zero on 2018/11/19.
//  Copyright © 2018年 Zero. All rights reserved.
//

#import "UIViewController+iconAndTip.h"
#import <objc/runtime.h>

static char UIViewControllerTipLabelKey;
static char UIViewControllerIconViewKey;


@implementation UIViewController (iconAndTip)
CGFloat _cur_tip_top = 0.0f;
- (void)showAttributedTip:(NSAttributedString *)tip {
    [self showAttributedTip:tip top:200 icon:nil];
}

- (void)showAttributedTip:(NSAttributedString *)tip top:(CGFloat)top icon:(UIImage *)icon {
    UIImageView *_iconView = nil;
    _cur_tip_top = top;
    if (icon) {
        _iconView = [self iconViewWithIcon:icon];
    }
    UILabel *_tipLabel = [self tipLabel];
    [_iconView setHidden:NO];
    [_tipLabel setAttributedText:tip];
    [_tipLabel setHidden:NO];
}

- (void)showTip:(NSString *)tip {
    [self showTip:tip top:200 icon:nil];
}

- (UILabel *)tipLabel {
    UILabel *_tipLabel = objc_getAssociatedObject(self, &UIViewControllerTipLabelKey);
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [_tipLabel setNumberOfLines:0];
        [_tipLabel setTextColor:UIColor.lightGrayColor];
        [_tipLabel setFont:[UIFont systemFontOfSize:16]];
        [_tipLabel setTextAlignment:NSTextAlignmentCenter];
        
        [self.view addSubview:_tipLabel];
        _tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[_tipLabel]",_cur_tip_top] options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tipLabel)];
        [self.view addConstraints:constraints];
        
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-25-[_tipLabel]-25-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tipLabel)];
        [self.view addConstraints:constraints];
        
        objc_setAssociatedObject(self, &UIViewControllerTipLabelKey, _tipLabel, OBJC_ASSOCIATION_ASSIGN);
        
    }
    return _tipLabel;
    
}

- (UIImageView *)iconViewWithIcon:(UIImage *)icon {
    UIImageView *_iconView = objc_getAssociatedObject(self, &UIViewControllerIconViewKey);
    if (!_iconView) {
        _iconView = [[UIImageView alloc]initWithImage:icon];
        _iconView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_iconView];
        
        NSLayoutConstraint *hor = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_iconView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:1.0];
        [self.view addConstraint:hor];
        
        NSArray *vers = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[_iconView]",_cur_tip_top] options:0 metrics:nil views:NSDictionaryOfVariableBindings(_iconView)];
        [self.view addConstraints:vers];
        
        objc_setAssociatedObject(self, &UIViewControllerIconViewKey, _iconView, OBJC_ASSOCIATION_ASSIGN);
        
        _cur_tip_top += _iconView.bounds.size.height + 20; //15是icon 和 tip之间的距离
    }
    return _iconView;
}

- (void)showTip:(NSString *)tip top:(CGFloat)top icon:(UIImage *)icon {
    UIImageView *_iconView = nil;
    _cur_tip_top = top;
    if (icon) {
        _iconView = [self iconViewWithIcon:icon];
    }
    UILabel *_tipLabel = [self tipLabel];
    [_iconView setHidden:NO];
    [_tipLabel setText:tip];
    [_tipLabel setHidden:NO];
}

- (void)hideTip {
    UILabel *_tipLabel = objc_getAssociatedObject(self, &UIViewControllerTipLabelKey);
    UIImageView *_iconView = objc_getAssociatedObject(self, &UIViewControllerIconViewKey);
    [_tipLabel setHidden:YES];
    [_iconView setHidden:YES];
}
@end
