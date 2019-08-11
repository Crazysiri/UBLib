# LenzAlbum

### 说明：
### 相册选择 和 相册浏览
### 支持多种数据源：
### 1.网络url
### 2.本地路径
### 3.PHAsset

### 版本说明
v0.0.2
1.支持视频浏览和选择
LenzImageBrowserSource *source = [[LenzImageBrowserSourceAlbum alloc] initWithType:PHAssetMediaTypeVideo];
LenzImagePickerController *picker = [[LenzImagePickerController alloc] initWithSource:source] ;

v0.0.3
1.图片选择 添加底部tip
LenzImagePickerController *picker = [[LenzImagePickerController alloc] initWithSource:source] ;
picker.bottomViewTip = @"只能选择3张";

v0.0.4:
1.添加LenzImageBrowserSourceComplex 类
可以从不同的数据源获取资源（图片，视频）
主要处理多种情况的数据源混合在一起的情况，（url，path，PHAsset）
会根据不同的source显示
具体看demo ViewController-》browseMutilThings方法

## LenzImageBrowser
1.可通过：
- (void)setNavigationLeftButton:(void(^)(UIButton *button))block needNew:(BOOL)needNew;
- (void)setNavigationRightButton:(void(^)(UIButton *button))block needNew:(BOOL)needNew;

@property (nonatomic, strong,readonly) UILabel *navigationTitleLabel;

自定义UI（左右按钮，标题）
2.功能：1）照片浏览  2）可选择是否删除 3）删除回调   4）设置当前索引。5）数据变化刷新UI 


## LenzImagePickerController
1.通过设置LenzImagePickerControllerConfig 可配置相关属性，例如没图的提示，图片资源，背景颜色。都是有默认值的
2.根据不同数据源 浏览照片（url，PHAssets，path）
3.可通过：
- (void)setNavigationRightButton:(void(^)(UIButton *button))block needNew:(BOOL)needNew;

//通过LenzImagePickerBottomView协议 可自定义 bottomView 默认的是TJLBottomEditView，强转出来即可使用
@property (strong, nonatomic) UIView <LenzImagePickerBottomView> * bottomEditView;

定制UI，包括底部UI，设置遵从协议的bottomeView，有默认的TJLBottomEditView


## 依赖库
pod 'Masonry'
pod 'SDWebImage'
pod 'UIViewController_iconAndTip',:git=>'https://git.coding.net/crazysiri/UIViewController_iconAndTip.git'



具体用法 详见demo
