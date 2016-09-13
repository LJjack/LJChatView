//
//  LJShortVideoPlayView.h
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/9.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LJShortVideoPlayView : UIView

@property (nonatomic, copy, readonly) NSString *videoPath;

@property (nonatomic, strong, readonly) UIImage *aFrameImage;

- (instancetype)initWithFrame:(CGRect)frame videoPath:(NSString *)videoPath aFrameImage:(UIImage *)aFrameImage;

- (void)play;
- (void)stop;

@end
