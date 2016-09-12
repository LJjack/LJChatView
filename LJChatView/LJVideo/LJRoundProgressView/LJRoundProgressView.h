//
//  LJRoundProgressView.h
//  LJRoundProgressView
//
//  Created by 刘俊杰 on 16/8/1.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  圆形进度条,像微信加载视频
 */
@interface LJRoundProgressView : UIView

@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, strong) UIImage *startImage;

- (void)dismissWithAnimated:(BOOL)animated;

@end
