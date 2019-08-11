//
//  LenzImageBrowserCell.h
//  LenzBusiness
//
//  Created by Zero on 2018/12/25.
//  Copyright © 2018年 LenzTech. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MBImageScrollView;

@interface LenzImageBrowserCell : UICollectionViewCell

@property (nonatomic, weak,readonly) MBImageScrollView *scrollView;

@property (nonatomic,strong) UIButton *videoPlayBtn;
@property (nonatomic,copy) void (^videoPlayBtnClickBlock)(UIButton *sender);

- (void)showVideoPlay:(BOOL)show;

@end

NS_ASSUME_NONNULL_END
