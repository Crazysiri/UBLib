//
//  LenzImageBrowser
//  MannerBar
//
//  Created by qiuyoubo on 2018-12-25.
//  Copyright (c) 2018年 user. All rights reserved.
//

#import "LenzImageBrowser.h"
#import "MBImageScrollView.h"
#import "LenzImageBrowserCell.h"
#import <Photos/Photos.h>

#import "Masonry.h"

#import <AVKit/AVKit.h>

@interface LenzImageBrowser ()
<
UICollectionViewDelegate
,UICollectionViewDataSource
,UICollectionViewDelegateFlowLayout
>

//view
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIButton *navigationLeftButton;

@property (nonatomic, strong) UIButton *navigationRightButton;

@property (nonatomic, strong) UILabel *navigationTitleLabel;


//data
@property (nonatomic, strong) LenzImageBrowserSource *source;

@property (nonatomic,assign) NSInteger totalCount;

@end
@implementation LenzImageBrowser


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - init

- (id)initWithSource:(LenzImageBrowserSource *)source {
    if (self = [super init]) {
        self.enableDelete = YES;
        self.source = source;
        __weak typeof(self) weakself = self;
        [self setNavigationLeftButton:^(UIButton *button) {
            [button setTitle:@"返回" forState:UIControlStateNormal];
            [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
            button.frame = CGRectMake(0, 0, 35, 35);
            [button addTarget:weakself action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

        } needNew:NO];
        
        [self setNavigationRightButton:^(UIButton *button) {
            [button setTitle:@"删除" forState:UIControlStateNormal];
            [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
            button.frame = CGRectMake(0, 0, 35, 35);
            [button addTarget:weakself action:@selector(handleDeleteAction:) forControlEvents:UIControlEventTouchUpInside];
        } needNew:NO];
        
        //注册数据变化通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectsChanged) name:kLenzImageBrowserSourceObjectsChangedNotification object:nil];
    
        
        self.totalCount = weakself.source.count;

    }
    return self;
}

///数据变化通知
- (void)objectsChanged {
    
    __weak typeof(self) weakself = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        
        //如果没有了就不更新了
        if (weakself.source.count == 0) {
            return;
        }
        weakself.totalCount = weakself.source.count;
        
        //如果两个值相等说明：删除了 类似 9/9 这种情况，所以当他们相等的时候要减1
        //selectedIndex 从 0开始。所以最大也要比count小1
        if (weakself.selectedIndex == weakself.source.count) {
            weakself.selectedIndex --;
        }
        
        //更新title
        [weakself updateTitle];
        
        [weakself.collectionView reloadData];
        
    });
}


#pragma mark - lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    self.view.backgroundColor = [UIColor blackColor];
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self.collectionView registerClass:LenzImageBrowserCell.class forCellWithReuseIdentifier:@"LenzImageBrowserCell"];
    
    
    if (!self.enableDelete) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    __weak typeof(self) weakself = self;
    
    if (self.source.count == 0) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:weakself.selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    });

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateTitle];
  
}

#pragma mark - UI


- (void)updateTitle
{
    self.navigationTitleLabel.text = [NSString stringWithFormat:@"%@ / %@",@(self.selectedIndex + 1),@(self.totalCount) ];
    self.navigationItem.titleView = self.navigationTitleLabel;
}

#pragma mark - public methods

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    //如果有collectionView 说明 已经过了viewDidLoad 有实例了
    //直接跳转
    if (_collectionView) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

/*
 一般用于 追加数据或者重设数据
 1.调用LenzImageBrowserSource appendObjects 或者 setObjects
 2.reload
 */
- (void)reload {
    [self.collectionView reloadData];
}

#pragma mark - event

//点击了返回按钮
- (void)backButtonPressed:(id)sender
{
    if (self.navigationController) {
        //如果就一个的话 说明是root而非push进来的
        if (self.navigationController.viewControllers.count == 1) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else { //否则就是push
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {//没有navigationController可能也是addChildController & addSubview（忽略这种情况以后就只剩 present了）
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)handleDeleteAction:(id)sender {
    
    __weak typeof(self) weakself = self;
    
    [self.source deleteObjectAtIndex:_selectedIndex completion:^(NSDictionary * result) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!result) {
                return;
            }
            
            //有result 说明删除成功
            if (weakself.deleteCompletionBlock) {
                weakself.deleteCompletionBlock(@[result]);
            }
            //删没了直接返回
            if (weakself.source.count == 0) {
                [weakself backButtonPressed:nil];
            }

        });
        
    }];
}


#pragma mark  UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGRect visibleBounds = scrollView.bounds;
    _selectedIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    if (_selectedIndex < 0) {
        _selectedIndex = 0;
    }
    [self updateTitle];
}

#pragma mark - UICollectionView delegate datasource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"LenzImageBrowserCell" forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(LenzImageBrowserCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    

    [cell.scrollView startLoading:YES];
    cell.scrollView.imageView.image = nil;
    
    id <LenzImageSourceObject> object = [self.source objectAtIndex:indexPath.row];
    
    if (object.type == LenzSourceObjectTypeVideo) {
        [cell showVideoPlay:YES];
        [cell.videoPlayBtn setImage:[UIImage imageNamed:@"videocard_play" inBundle:self.resourceBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    } else {
        [cell showVideoPlay:NO];
    }
    __weak typeof(self) weakself = self;
    
    //如果是视频 播放按钮点击事件
    cell.videoPlayBtnClickBlock = ^(UIButton * _Nonnull sender) {
        [object getVideoPlayerItem:^(AVPlayerItem *item) {
            dispatch_async(dispatch_get_main_queue(), ^{
                AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
                AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
                playerVC.showsPlaybackControls = YES;
                playerVC.player = player;
                [weakself presentViewController:playerVC animated:YES completion:nil];
            });

        }];

    };
    
    LenzImageFetchParams *params = [[LenzImageFetchParams alloc] init];
    params.index = indexPath.row;
    params.imageView = cell.scrollView.imageView;
    params.size = PHImageManagerMaximumSize;
    [self.source fetchImage:params completion:^(UIImage * image) {
        if (image) {
            [cell.scrollView updateLayout];
            [cell.scrollView startLoading:NO];
        }
    }];

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.source.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = collectionView.bounds.size;
    return CGSizeMake(size.width, size.height - 64);
}

#pragma mark - getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
    }
    return _collectionView;
}

- (UILabel *)navigationTitleLabel {
    if (!_navigationTitleLabel) {
        _navigationTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
        _navigationTitleLabel.textAlignment = NSTextAlignmentCenter;
        _navigationTitleLabel.font = [UIFont systemFontOfSize:16];
        _navigationTitleLabel.textColor = [UIColor blackColor];
    }
    
    return _navigationTitleLabel;
}

#pragma mark - for UI

- (void)setNavigationLeftButton:(void(^)(UIButton *button))block needNew:(BOOL)needNew {
    UIButton *button = self.navigationLeftButton;
    if (needNew || !button) {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.navigationLeftButton = button;
    }
    
    if (block) block(button);
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)setNavigationRightButton:(void(^)(UIButton *button))block needNew:(BOOL)needNew {
    UIButton *button = self.navigationRightButton;
    if (needNew || !button) {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.navigationRightButton = button;
    }
    
    if (block) block(button);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}


#pragma mark - for resource

- (NSBundle *)resourceBundle {
    if (!_resourceBundle) {
        NSBundle *bundle = [NSBundle bundleForClass:self.class];
        NSURL *url = [bundle URLForResource:@"LenzAlbumBundle" withExtension:@"bundle"];
        NSBundle *imageBundle = [NSBundle bundleWithURL:url];
        _resourceBundle = imageBundle;
    }
    return _resourceBundle;
}
@end

