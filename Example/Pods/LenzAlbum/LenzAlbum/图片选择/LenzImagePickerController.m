//
//  PPZGridViewController.m
//  ppz_businessman
//
//  Created by ronggang wang on 2018/7/5.
//  Copyright © 2018年 paipaizhuan. All rights reserved.
//

#import "LenzImagePickerController.h"
#import "TJLGridCollectionCell.h"
#import "TJLBottomEditView.h"

#import "Masonry.h"
#import "LenzAlbumDefines.h"

#import "UIViewController+iconAndTip.h"
#import "NSAttributedString+LenzAlbumAddition.h"

@interface LenzImagePickerController ()
<
UICollectionViewDelegate
, UICollectionViewDataSource
, TJLGridCollectionCellDelegate
>
{
    //每一个小格的size
    CGSize _currentGridSize;
}

#pragma mark - config
@property (nonatomic, strong) LenzImagePickerControllerConfig *config;

#pragma mark - view
@property (strong, nonatomic) UICollectionView *collectionView;

@property (nonatomic, strong) UIButton *navigationRightButton;

#pragma mark - data

//已经选择的图片
@property (copy,nonatomic) NSArray *selectedIdentfiers;

@property (nonatomic, strong) LenzImageBrowserSource *source;


#pragma mark - result

/**
 选中的图片资源asset
 */
@property (strong, nonatomic) NSMutableArray *selectImageArray;



@end

@implementation LenzImagePickerController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - initial

- (id)initWithConfig:(LenzImagePickerControllerConfig *)config source:(LenzImageBrowserSource *)source {
    self = [super init];
    if (self) {
        [self configSelf:config source:source];
    }
    return self;
}

- (id)initWithSource:(LenzImageBrowserSource *)source {
    self = [super init];
    if (self) {
        [self configSelf:nil source:source];
    }
    return self;
}


- (void)configSelf:(LenzImagePickerControllerConfig *)config source:(LenzImageBrowserSource *)source {
    self.config = config?config:LenzImagePickerControllerConfig.defaultConfig;
    self.source = source;
    self.title = @"相机胶卷";
    [self setDefaultNavigationRightItem];
    
    //注册数据变化通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectsChanged) name:kLenzImageBrowserSourceObjectsChangedNotification object:nil];
    
}

///数据变化通知
- (void)objectsChanged {
    [self reload];
}


#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUI];
    
    [self reload];

}

- (void)setUI {
    
    
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }else {
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    
    [self.view setBackgroundColor:self.config.backgroundColor];
    
    [self.collectionView registerNib:[TJLGridCollectionCell cellNib] forCellWithReuseIdentifier:[TJLGridCollectionCell cellIdentifier]];
    
    self.bottomEditView = [[TJLBottomEditView alloc] init];

    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.bottomEditView.mas_top);
    }];
    
    
}

- (void)setBottomEditView:(UIView <LenzImagePickerBottomView> *)bottomEditView {
    if (_bottomEditView != bottomEditView) {
        
        if (_bottomEditView) {
            [_bottomEditView removeFromSuperview];
            _bottomEditView = nil;
        }
        
        _bottomEditView = bottomEditView;
        [bottomEditView.chooseButton addTarget:self action:@selector(chooseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        if (self.selectImageArray.count>0) {
            [bottomEditView setButtonTitleColorHighlighted:self.selectImageArray.count];//初始化时显示的数量
        }
        
        if (_collectionView) { //说明已经执行过viewDidLoad
            [self.view addSubview:bottomEditView];
            
            [bottomEditView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.equalTo(self.view);
                make.height.offset(50);
            }];
        }
        if (self.bottomViewTip) {
            [bottomEditView setTip:self.bottomViewTip];
        } else if (self.attributedBottomViewTip) {
            [bottomEditView setAttributedTip:self.attributedBottomViewTip];
        }
    }
}



#pragma mark - public methods

/*
 一般用于 追加数据或者重设数据
 1.调用LenzImageBrowserSource appendObjects 或者 setObjects
 2.reload
 */
- (void)reload {
    __weak typeof(self) weakself = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (weakself.source.count == 0) {
            [weakself showAttributedTip:weakself.config.noPhotoTip];
        } else {
            [weakself hideTip];
        }
        
        [weakself.collectionView reloadData];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            __strong typeof(weakself) strongself = weakself;
            
            CGFloat scrollContentHeight = strongself.collectionView.contentSize.height;
            CGFloat scrollHeight = strongself.collectionView.bounds.size.height;
            if (scrollContentHeight > scrollHeight) {
                //滚动到最后
                [strongself.collectionView setContentOffset:CGPointMake(0, scrollContentHeight - scrollHeight) animated:NO];
            }
            
            
        });
    });

}

- (void)setBottomViewTip:(NSString *)bottomViewTip {
    _bottomViewTip = bottomViewTip;
    if (self.bottomEditView) {
        [self.bottomEditView setTip:bottomViewTip];
    }
}

- (void)setAttributedBottomViewTip:(NSAttributedString *)attributedBottomViewTip {
    _attributedBottomViewTip = attributedBottomViewTip;
    if (self.bottomEditView) {
        [self.bottomEditView setAttributedTip:attributedBottomViewTip];
    }
}

#pragma mark - events

- (void)chooseButtonClicked:(UIButton *)sender {
    if (self.selectImageArray.count > 0) {
        if (self.pickerSuccessedHanlder) {
            self.pickerSuccessedHanlder(self.selectImageArray);
        }
        [self dismiss];
    }
}
#pragma mark --- Collection

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.source.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TJLGridCollectionCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[TJLGridCollectionCell cellIdentifier] forIndexPath:indexPath];

    //设置选择和未选择
    cell.checkImageView.image = [UIImage imageNamed:@"question_weixuanzhong" inBundle:self.config.resourceBundle compatibleWithTraitCollection:nil];
    cell.checkImageView.highlightedImage = [UIImage imageNamed:@"question_xuanzhong" inBundle:self.config.resourceBundle compatibleWithTraitCollection:nil];
    
    cell.delegate = self;
    cell.tag = indexPath.item;
    
    id <LenzImageSourceObject>object = [self.source objectAtIndex:indexPath.item];
    
    //视频显示时长
    if (object.type == LenzSourceObjectTypeVideo) {
        [cell showVideoDuration:object.videoTime];
    } else {
        [cell hideVideoDuration];
    }

    //改变选择状态相关
    [self changeCellSelectStatus:cell selectedItem:object];
    
    CGFloat scale = UIScreen.mainScreen.scale;

    LenzImageFetchParams *params = [[LenzImageFetchParams alloc] init];
    params.index = indexPath.item;
    params.imageView = cell.gridImageView;
    params.size = CGSizeMake(_currentGridSize.width * scale, _currentGridSize.height * scale);
    
    [self.source fetchImage:params completion:nil];
    
    return cell;
}

- (void)changeCellSelectStatus:(TJLGridCollectionCell *)cell selectedItem:(id)selectedItem {
    if ([self.selectImageArray containsObject:selectedItem]){
        cell.selected=YES;
        cell.checkView.hidden = NO;
        return;
    }
    
    //如果不包括并且到达最大选择数量，要让选择框消失
    if (self.config.maxSelectedCount == self.selectImageArray.count) {
        cell.checkView.hidden = YES;
    } else {
        cell.checkView.hidden = NO;
    }
}

#pragma mark --- TJLGridCollectionCellDelegate
- (void)didPreviewAssetsViewCell:(TJLGridCollectionCell *)assetsCell {
    
    if (self.previewClickBlock) {
        self.previewClickBlock(assetsCell.tag,self.source);
    }
}

- (void)didSelectItemAssetsViewCell:(TJLGridCollectionCell *)assetsCell {//选中响应事件
    if (self.config.maxSelectedCount != -1 && self.selectImageArray.count == self.config.maxSelectedCount ) {
        NSString *alertString = [NSString stringWithFormat:@"您最多只能选择%ld张照片或视频",(long)(self.config.maxSelectedCount)];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:nil];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:alertString preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];

        [assetsCell reduceCheckImage];
        return;
    }
    
    id <LenzImageSourceObject> object = [self.source objectAtIndex:assetsCell.tag];
    
    [self.selectImageArray addObject:object];
    
    [self.bottomEditView setButtonTitleColorHighlighted:self.selectImageArray.count];//选择之后显示的数量
    
    if (self.config.maxSelectedCount == self.selectImageArray.count) {
        for (NSIndexPath *indexPath in self.collectionView.indexPathsForVisibleItems) {
            TJLGridCollectionCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            id <LenzImageSourceObject> object = [self.source objectAtIndex:indexPath.item];
            [self changeCellSelectStatus:cell selectedItem:object];
        }
    }
}

- (void)didDeselectItemAssetsViewCell:(TJLGridCollectionCell *)assetsCell {//取消选中响应事件
    
    id <LenzImageSourceObject> object = [self.source objectAtIndex:assetsCell.tag];

    if ([self.selectImageArray containsObject:object]) {
        [self.selectImageArray removeObject:object];
    }
    
    [self.bottomEditView setButtonTitleColorNormal:self.selectImageArray.count];
    
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForVisibleItems) {
        TJLGridCollectionCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        id <LenzImageSourceObject> object = [self.source objectAtIndex:indexPath.item];
        [self changeCellSelectStatus:cell selectedItem:object];
    }
}
#pragma mark --- dismiss
- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark --- 懒加载


- (NSMutableArray *)selectImageArray {
    if (!_selectImageArray) {
        _selectImageArray = [[NSMutableArray alloc] init];
    }
    return _selectImageArray;
}


- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        CGSize size = UIScreen.mainScreen.bounds.size;
        
        CGFloat itemHeight = (size.width - (self.config.gridItemNumberOfColumns + 1) * self.config.gridSpace) / self.config.gridItemNumberOfColumns;
        CGSize itemSize = CGSizeMake(itemHeight, itemHeight);
        
        _currentGridSize = itemSize;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = itemSize;
        layout.minimumLineSpacing = self.config.gridSpace;
        layout.minimumInteritemSpacing = self.config.gridSpace;
        layout.sectionInset = UIEdgeInsetsMake(self.config.gridSpace, self.config.gridSpace, self.config.gridSpace, self.config.gridSpace);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        NSLog(@"_collectionView的y值：%f",_collectionView.frame.size.height);
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;

        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}


#pragma mark - for UI

- (void)setNavigationRightButton:(void(^)(UIButton *button))block needNew:(BOOL)needNew {
    UIButton *button = self.navigationRightButton;
    if (needNew || !button) {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.navigationRightButton = button;
        [button addTarget:self action:@selector(rightBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (block) block(button);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

#pragma mark - for default UI and Click

- (void)setDefaultNavigationRightItem {
    
    UIBarButtonItem *btnItem=[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClicked)];
    [btnItem setTitleTextAttributes:@{NSForegroundColorAttributeName:RGBCOLOR_lenzAlbum(65, 148, 246)} forState:(UIControlStateNormal)];
    self.navigationItem.rightBarButtonItem=btnItem;
    
}

- (void)rightBarButtonClicked {
    [self dismiss];
}

@end



@implementation LenzImagePickerControllerConfig

+ (instancetype)defaultConfig {
    LenzImagePickerControllerConfig *config = [[LenzImagePickerControllerConfig alloc] init];
    config.gridItemNumberOfColumns = 4;
    config.gridSpace = 4;
    config.backgroundColor = [UIColor whiteColor];
    config.maxSelectedCount = -1;
    config.noPhotoTip = [NSAttributedString lenz_attributedStringCustomWithStrings:@[@"无视频或照片",@"\n你可以使用相机拍摄照片或视频"] Attribute:@[@{NSFontAttributeName:[UIFont systemFontOfSize:16]},@{NSFontAttributeName:[UIFont systemFontOfSize:14]}]];
    
    NSBundle *bundle = [NSBundle bundleForClass:self];
    NSURL *url = [bundle URLForResource:@"LenzAlbumBundle" withExtension:@"bundle"];
    NSBundle *imageBundle = [NSBundle bundleWithURL:url];

    config.resourceBundle = imageBundle;
    
    return config;
}

@end
