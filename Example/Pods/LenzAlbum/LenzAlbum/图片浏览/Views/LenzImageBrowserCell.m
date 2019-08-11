//
//  LenzImageBrowserCell.m
//  LenzBusiness
//
//  Created by Zero on 2018/12/25.
//  Copyright © 2018年 LenzTech. All rights reserved.
//

#import "LenzImageBrowserCell.h"

#import "MBImageScrollView.h"

#import "Masonry.h"

@interface LenzImageBrowserCell ()

@property (nonatomic, weak) MBImageScrollView *scrollView;

@end

@implementation LenzImageBrowserCell


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        [self addSubview:self.videoPlayBtn];
        [self.videoPlayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    }
    return self;
}

- (void)didPlayBtnClick:(UIButton *)sender {
    if (self.videoPlayBtnClickBlock) {
        self.videoPlayBtnClickBlock(sender);
    }
}

- (void)showVideoPlay:(BOOL)show {
    self.videoPlayBtn.hidden = !show;
}

- (MBImageScrollView *)scrollView {
    if (!_scrollView) {
        MBImageScrollView *sc = [[MBImageScrollView alloc] initWithFrame:CGRectZero];
        _scrollView = sc;
        [self.contentView addSubview:sc];
    }
    return _scrollView;
}

- (UIButton *)videoPlayBtn {
    if (!_videoPlayBtn) {
        _videoPlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_videoPlayBtn setImage:[[UIImage alloc] init] forState:UIControlStateSelected];
        [_videoPlayBtn addTarget:self action:@selector(didPlayBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _videoPlayBtn;
}

@end
