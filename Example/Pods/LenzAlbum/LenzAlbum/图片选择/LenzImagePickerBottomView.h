//
//  LenzImagePickerBottomView.h
//  demo
//
//  Created by Zero on 2019/1/18.
//  Copyright © 2019 Zero. All rights reserved.
//

#ifndef LenzImagePickerBottomView_h
#define LenzImagePickerBottomView_h
#import <UIKit/UIKit.h>

@protocol LenzImagePickerBottomView <NSObject>

@property (strong, nonatomic) UIButton *chooseButton;

//设置选择的数量（normal）
- (void)setButtonTitleColorNormal:(NSInteger)count;
//设置选择的数量（highlighted）
- (void)setButtonTitleColorHighlighted:(NSInteger)count;
//设置tip
- (void)setTip:(NSString *)tip;
//设置tip
- (void)setAttributedTip:(NSAttributedString *)attriTip;
@end
#endif /* LenzImagePickerBottomView_h */
