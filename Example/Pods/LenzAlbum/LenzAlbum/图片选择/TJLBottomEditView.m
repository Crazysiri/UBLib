//
//  TJLBottomEditView.m
//  PhotoManagement
//
//  Created by Oma-002 on 17/1/18.
//  Copyright © 2017年 com.oma.matec. All rights reserved.
//

#import "TJLBottomEditView.h"

#import "LenzAlbumDefines.h"


#define WIDTH [[UIScreen mainScreen] bounds].size.width
#define HEIGHT [[UIScreen mainScreen] bounds].size.height

@interface TJLBottomEditView ()

@property (strong, nonatomic) UIView *lineView;

@property (strong, nonatomic) UILabel *selectedCountLabel;

@property (strong, nonatomic) UILabel *tipLabel;

@end

@implementation TJLBottomEditView

@synthesize chooseButton = _chooseButton;


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.lineView];
        [self addSubview:self.chooseButton];
        [self addSubview:self.selectedCountLabel];
        [self addSubview:self.tipLabel];
    }
    return self;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
        _lineView.backgroundColor = UIColorFromHex_lenzAlbum(0xbfbfbf);
    }
    return _lineView;
}

- (UIButton *)chooseButton {
    if (!_chooseButton) {
        _chooseButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 55, 14, 45, 16)];
        [_chooseButton setTitleColor:UIColorFromHex_lenzAlbum(0xb4e2b9) forState:UIControlStateNormal];
        _chooseButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_chooseButton setTitle:@"选择" forState:UIControlStateNormal];
    }
    return _chooseButton;
}

//设置tip
- (void)setTip:(NSString *)tip {
    self.tipLabel.text = tip;
}

//设置tip
- (void)setAttributedTip:(NSAttributedString *)attriTip {
    self.tipLabel.attributedText = attriTip;
}

- (void)setButtonTitleColorNormal:(NSInteger)count {
    if (count == 0) {
        self.selectedCountLabel.hidden = YES;
        [self.chooseButton setTitleColor:UIColorFromHex_lenzAlbum(0xb4e2b9) forState:UIControlStateNormal];
    } else {
        self.selectedCountLabel.text = [NSString stringWithFormat:@"%ld",(long)count];
        self.selectedCountLabel.transform = CGAffineTransformMakeScale(0.5, 0.5);
        [self selectLabelAnimation];
    }
}

- (void)setButtonTitleColorHighlighted:(NSInteger)count {
    [self.chooseButton setTitleColor:UIColorFromHex_lenzAlbum(0x09bb07) forState:UIControlStateNormal];
    
    self.selectedCountLabel.hidden = NO;
    self.selectedCountLabel.text = [NSString stringWithFormat:@"%ld",(long)count];
    [self selectLabelAnimation];
}

- (void)selectLabelAnimation {
    self.selectedCountLabel.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:8 options:UIViewAnimationOptionCurveLinear animations:^{
        self.selectedCountLabel.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (UILabel *)selectedCountLabel {
    if (!_selectedCountLabel) {
        _selectedCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(WIDTH - 73, 11, 20, 20)];
        _selectedCountLabel.textColor = [UIColor whiteColor];
        _selectedCountLabel.backgroundColor = UIColorFromHex_lenzAlbum(0x09bb07);
        _selectedCountLabel.textAlignment = NSTextAlignmentCenter;
        _selectedCountLabel.layer.masksToBounds = YES;
        _selectedCountLabel.layer.cornerRadius = 10;
        _selectedCountLabel.font = [UIFont systemFontOfSize:16];
        _selectedCountLabel.hidden = YES;
    }
    return _selectedCountLabel;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 11, WIDTH - 100, 20)];
        _tipLabel.textColor = UIColor.darkGrayColor;
        _tipLabel.font = [UIFont systemFontOfSize:13];
    }
    return _tipLabel;
}

@end
