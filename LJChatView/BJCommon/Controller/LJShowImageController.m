//
//  LJShowImageController.m
//  BJShop
//
//  Created by 刘俊杰 on 16/11/2.
//  Copyright © 2016年 不囧. All rights reserved.
//

#import "LJShowImageController.h"

#import "UIImage+LJQRCode.h"
#import "UIViewController+LJHUD.h"


@interface LJShowImageController ()<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation LJShowImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
    _scrollView.frame = self.view.bounds;
    _imageView.frame = self.view.bounds;
    _imageView.center = _scrollView.center;
    _scrollView.contentSize = self.view.bounds.size;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (instancetype)showImageControllerWithImage:(UIImage *)image {
    LJShowImageController *showImageC = [[LJShowImageController alloc] init];
    showImageC.image = image;
    return showImageC;
}

+ (instancetype)showImageControllerWithFile:(NSString *)imgPath {
    LJShowImageController *showImageC = [[LJShowImageController alloc] init];
    showImageC.image = [UIImage imageWithContentsOfFile:imgPath];
    return showImageC;
}

- (void)onTapImg {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)onLongPressedImg:(UIGestureRecognizer *)ges {
    if (ges.state == UIGestureRecognizerStateBegan) {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
 
        NSString *QRString = [UIImage lj_checkWithImage:self.imageView.image];
        if (QRString) {
            [alertC addAction:[UIAlertAction actionWithTitle:@"识别图中的二维码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
        }
        [alertC addAction:[UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 保存到相册
            if (self.image) {
                UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
                [self lj_showHint:@"保存成功"];
            }
        }]];
        [alertC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertC animated:YES completion:nil];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    CGSize contentSize = scrollView.contentSize;
    CGPoint centerPoint = scrollView.center;
    CGFloat imgCenterX = MAX(contentSize.width*0.5, centerPoint.x);
    CGFloat imgCenterY = MAX(contentSize.height*0.5, centerPoint.y);
    self.imageView.center = CGPointMake(imgCenterX, imgCenterY);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

#pragma mark - Getters And Setters

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.minimumZoomScale = 0.6;
        _scrollView.maximumZoomScale = 1.6;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        _imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapImg)];
        [_imageView addGestureRecognizer:tap];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressedImg:)];
        [_imageView addGestureRecognizer:longPress];
    }
    return _imageView;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    self.imageView.image = image;
}

@end
