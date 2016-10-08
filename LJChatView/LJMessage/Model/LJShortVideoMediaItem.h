//
//  LJShortVideoMediaItem.h
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/9.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "JSQMediaItem.h"

@interface LJShortVideoMediaItem : JSQMediaItem

@property (nonatomic, strong) NSString *videoPath;

/**
 一帧图片
 */
@property (nonatomic, strong) UIImage *aFrameImage; 

- (instancetype)initWithVideoPath:(NSString *)videoPath aFrameImage:(UIImage *)aFrameImage;

- (void)play;
- (void)pause;

@end
