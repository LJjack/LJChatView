//
//  Created by Jesse Squires

//  License
//  Copyright (c) 2014 Jesse Squires
//

#import "JSQMediaItem.h"

NS_ASSUME_NONNULL_BEGIN


/**
 *  The `JSQAudioMediaItem` class is a concrete `JSQMediaItem` subclass that implements the `JSQMessageMediaData` protocol
 *  and represents an audio media message. An initialized `JSQAudioMediaItem` object can be passed
 *  to a `JSQMediaMessage` object during its initialization to construct a valid media message object.
 *  You may wish to subclass `JSQAudioMediaItem` to provide additional functionality or behavior.
 */
@interface JSQAudioMediaItem : JSQMediaItem <JSQMessageMediaData, NSCoding, NSCopying>

/**
 *  A data object that contains an audio resource.
 */
@property (nonatomic, strong, nullable) NSString *audioPath;

/**
 *  音频时间
 */
@property (nonatomic, assign) NSInteger audioTime;


- (instancetype)initWithPath:(nullable NSString *)audioPath audioTime:(NSInteger)audioTime;


/**
 *  开始音频播放动画
 */
- (void)startAudioAnimating;

/**
 *  停止音频播放动画
 */
- (void)stopAudioAnimating;

/**
 *  判断是否正在播放音频
 *
 *  @return BOOL
 */
- (BOOL)isAudioAnimating;

@end

NS_ASSUME_NONNULL_END
