//
//  LJFullVideoView.h
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/13.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
/**
 *  目前只是微视频的全屏播放
 */
@interface LJFullVideoView : UIView

@property (nonatomic,   copy, readonly) NSString *videoPath;
@property (nonatomic, strong, readonly) UIImage  *coverImage;

- (instancetype)initWithVideoPath:(NSString *)videoPath coverImage:(UIImage *)coverImage;

- (void)showFullVideoView;

@end
