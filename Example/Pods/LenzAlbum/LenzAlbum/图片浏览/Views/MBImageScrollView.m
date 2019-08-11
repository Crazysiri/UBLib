//
//  MBImageScrollView.m
//  MannerBar
//
//  Created by liangw on 13-2-1.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "MBImageScrollView.h"

#import "Masonry.h"

@implementation MBImageScrollView

#pragma mark - Customs Methods
//双击过后设置图片的放大
- (void)handleDoubleTap:(UITapGestureRecognizer *)recongnizer
{
    float scale = self.zoomScale > self.minimumZoomScale ? self.minimumZoomScale : self.maximumZoomScale;
    CGPoint center = [recongnizer locationInView:self];
    CGRect zoomRect = CGRectZero;
    zoomRect.size.height = self.bounds.size.height / scale;
    zoomRect.size.width = self.bounds.size.width / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    NSLog(@"zoomRect = %@",NSStringFromCGRect(zoomRect));
    [self zoomToRect:zoomRect animated:YES];
}

- (void)startLoading:(BOOL)start {
    if (start) {
        [self.indicatorView startAnimating];
    } else {
        [self.indicatorView stopAnimating];
    }
}

- (void)_updateLayout {
    if (_imageView.image == nil) {
        return;
    }
    self.zoomScale = 1.0f;
    self.minimumZoomScale = 1.0f;
    //最大放大2倍
    self.maximumZoomScale = 2.0f;
    
    CGSize imageSize = _imageView.image.size;
    CGSize finalSize = self.bounds.size;
    //对图片进行屏幕的自适应
    if (imageSize.width > imageSize.height) {
        finalSize.height = imageSize.height * (finalSize.width/imageSize.width);
        if (finalSize.height > self.frame.size.height) {
            finalSize.width *= self.frame.size.height/finalSize.height;
            finalSize.height = self.frame.size.height;
        }
    }else {
        finalSize.width = imageSize.width*(finalSize.height/imageSize.height);
        if (finalSize.width > self.frame.size.width) {
            finalSize.height *= (self.frame.size.width/finalSize.width);
            finalSize.width = self.frame.size.width;
        }
    }
    _imageView.frame = CGRectMake(0, 0, finalSize.width, finalSize.height);
    [self setNeedsLayout];
}

- (void)updateLayout
{
    __weak typeof(self) sself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [sself _updateLayout];
    });
}
#pragma mark - init
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.autoresizesSubviews = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        
        [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.offset(50);
            make.center.equalTo(self);
        }];
        [self.indicatorView startAnimating];
        
        self.backgroundColor = [UIColor blackColor];
        self.delegate = self;
        //设置双击的手势识别
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
    }
    return self;
}
//缩小是总是显示在中心位置
- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _imageView.frame;
    
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    _imageView.frame = frameToCenter;
}

#pragma mark - UIScrollView delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}
- (void)dealloc
{

}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        //设置转圈圈
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicatorView = view;
        _indicatorView.backgroundColor = [UIColor clearColor];
        [self addSubview:_indicatorView];
    }
    return _indicatorView;
}

@end
