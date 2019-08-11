//
//  TJLGridCollectionCell.m
//  PhotoManagement
//
//  Created by Oma-002 on 17/1/13.
//  Copyright © 2017年 com.oma.matec. All rights reserved.
//

#import "TJLGridCollectionCell.h"


@interface TJLGridCollectionCell ()

@property (nonatomic, strong) CAGradientLayer *bottomMaskLayer;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation TJLGridCollectionCell

+ (UINib *)cellNib {
    return [UINib nibWithNibName:[self cellIdentifier] bundle:[NSBundle mainBundle]];
}

+ (NSString *)cellIdentifier {
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.contentView.layer addSublayer:self.bottomMaskLayer];
    [self.contentView bringSubviewToFront:self.timeLabel];
    
    [self.gridImageView setUserInteractionEnabled:YES];
    [self.checkView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selected:)];
    [self.gridImageView addGestureRecognizer:tap1];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkSelected:)];
    [self.checkView addGestureRecognizer:tap2];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bottomMaskLayer.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - 25, CGRectGetWidth(self.bounds), 25);
}

//预览
- (void)selected:(UITapGestureRecognizer *)tap {
    if ([self.delegate respondsToSelector:@selector(didPreviewAssetsViewCell:)]) {
        [self.delegate didPreviewAssetsViewCell:self];
    }
}
//选取
- (void)checkSelected:(UITapGestureRecognizer *)tap {
    if (self.selected) {
        self.selected = NO;
//        self.checkImageView.image = [UIImage imageNamed:@"grey"];
        if ([self.delegate respondsToSelector:@selector(didDeselectItemAssetsViewCell:)]) {
            [self.delegate didDeselectItemAssetsViewCell:self];
        }
    } else {
        self.selected = YES;
//        self.checkImageView.image = [UIImage imageNamed:@"green"];
        self.checkImageView.transform = CGAffineTransformMakeScale(0.6, 0.6);
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:5 options:UIViewAnimationOptionCurveLinear animations:^{
            self.checkImageView.transform = CGAffineTransformIdentity;
        } completion:nil];
        if ([self.delegate respondsToSelector:@selector(didSelectItemAssetsViewCell:)]) {
            [self.delegate didSelectItemAssetsViewCell:self];
        }
    }
}
- (void)reduceCheckImage {
    self.selected = NO;
    self.checkImageView.highlighted = NO;
    if ([self.delegate respondsToSelector:@selector(didDeselectItemAssetsViewCell:)]) {
        [self.delegate didDeselectItemAssetsViewCell:self];
    }
}
-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        self.checkImageView.highlighted = YES;
    }else{
        self.checkImageView.highlighted = NO;
    }
}

- (void)showVideoDuration:(NSString *)time {
    self.timeLabel.hidden = NO;
    self.bottomMaskLayer.hidden = NO;
    self.timeLabel.text = time;
}

- (void)hideVideoDuration {
    self.timeLabel.hidden = YES;
    self.bottomMaskLayer.hidden = YES;
}


- (CAGradientLayer *)bottomMaskLayer {
    if (!_bottomMaskLayer) {
        _bottomMaskLayer = [CAGradientLayer layer];
        _bottomMaskLayer.colors = @[
                                    (id)[[UIColor blackColor] colorWithAlphaComponent:0].CGColor ,
                                    (id)[[UIColor blackColor] colorWithAlphaComponent:0.15].CGColor ,
                                    (id)[[UIColor blackColor] colorWithAlphaComponent:0.35].CGColor ,
                                    (id)[[UIColor blackColor] colorWithAlphaComponent:0.6].CGColor
                                    ];
        _bottomMaskLayer.startPoint = CGPointMake(0, 0);
        _bottomMaskLayer.endPoint = CGPointMake(0, 1);
        _bottomMaskLayer.locations = @[@(0.15f),@(0.35f),@(0.6f),@(0.9f)];
        _bottomMaskLayer.borderWidth  = 0.0;
    }
    return _bottomMaskLayer;
}
@end
