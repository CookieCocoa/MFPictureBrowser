

#import "LocalImageViewController.h"
#import "MFPictureBrowser.h"
#import "MFDisplayPhotoCollectionViewCell.h"
#import <PINRemoteImage/PINImageView+PINRemoteImage.h>
#import "MFPictureBrowser/FLAnimatedImageView+TransitionImage.h"
@interface LocalImageViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
MFPictureBrowserDelegate
>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *picList;
@property (nonatomic, assign) NSInteger currentPictureIndex;
@end

@implementation LocalImageViewController

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 0, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.width - 20) collectionViewLayout:flow];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.bounces = NO;
    }
    return _collectionView;
}

- (NSMutableArray *)picList {
    if (!_picList) {
        _picList = @[
                     @"1.gif",
                     @"2.gif",
                     @"3.jpg",
                     @"4.jpg",
                     @"5.jpg"
                     ].mutableCopy;
    }
    return _picList;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[MFDisplayPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"reuseCell"];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.picList.count;
}

- (UICollectionViewCell *)collectionView: (UICollectionView *)collectionView
                  cellForItemAtIndexPath: (NSIndexPath *)indexPath {
    
    MFDisplayPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reuseCell" forIndexPath:indexPath];
    NSString *imageName = self.picList[indexPath.row];
    if ([imageName.pathExtension isEqualToString:@"gif"] || [imageName.pathExtension isEqualToString:@"webp"]) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSURL *imageUrl = [[NSBundle mainBundle] URLForResource:imageName withExtension:nil];
            FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:imageUrl]];
            if (animatedImage) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell.displayImageView animatedTransitionAnimatedImage:animatedImage];
                    [self configTagImageView:cell.tagImageView size:animatedImage.size pathExtension:imageName.pathExtension];
                });
            }
        });
    }else {
        
        UIImage *image = [UIImage imageNamed:imageName];
        cell.displayImageView.image = image;
        [self configTagImageView:cell.tagImageView size:image.size pathExtension:imageName.pathExtension];
    }
    
    
    return cell;
}

- (void)configTagImageView:(UIImageView *)tagImageView size:(CGSize)size pathExtension:(NSString *)pathExtension {
    CGFloat height = size.height * 320 / size.width;
    if (height > [UIScreen mainScreen].bounds.size.height) {
        tagImageView.image = [UIImage imageNamed:@"ic_messages_pictype_long_pic_30x30_"];
    }else if ([pathExtension isEqualToString:@"gif"] || [pathExtension isEqualToString:@"webp"]) {
        tagImageView.image = [UIImage imageNamed:@"ic_messages_pictype_gif_30x30_"];
    }
    tagImageView.alpha = 0;
    if (tagImageView.image) {
        tagImageView.alpha = 1;
    }
}

- (CGSize)collectionView: (UICollectionView *)collectionView
                  layout: (UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath: (NSIndexPath *)indexPath{
    return CGSizeMake(([UIScreen mainScreen].bounds.size.width - 20 - 20)/3, ([UIScreen mainScreen].bounds.size.width - 20 - 20)/3);
}

- (CGFloat)collectionView: (UICollectionView *)collectionView
                   layout: (UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex: (NSInteger)section{
    return 5.0f;
}

- (CGFloat)collectionView: (UICollectionView *)collectionView
                   layout: (UICollectionViewLayout*)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex: (NSInteger)section{
    return 5.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    MFDisplayPhotoCollectionViewCell *cell = (MFDisplayPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    MFPictureBrowser *browser = [[MFPictureBrowser alloc] init];
    browser.delegate = self;
    self.currentPictureIndex = indexPath.row;
    [browser showLocalImageFromView:cell.displayImageView picturesCount:self.picList.count currentPictureIndex:indexPath.row];
}

- (NSString *)pictureBrowser:(MFPictureBrowser *)pictureBrowser imageNameAtIndex:(NSInteger)index {
    return self.picList[index];
}

- (UIImageView *)pictureBrowser:(MFPictureBrowser *)pictureBrowser imageViewAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    MFDisplayPhotoCollectionViewCell *cell = (MFDisplayPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    return cell.displayImageView;
}

@end
