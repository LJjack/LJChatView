//
//  LJSoundManager.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/21.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJSoundManager.h"

@interface LJSoundManager ()

@property (nonatomic, strong) LJSoundPlayer *soundPlayer;

@property (nonatomic, strong) LJSoundRecord *soundRecord;

@end


@implementation LJSoundManager

+ (instancetype)sharedInstance {
    static LJSoundManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LJSoundManager alloc] init];
    });
    
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.soundPlayer = [[LJSoundPlayer alloc] init];
        self.soundRecord = [[LJSoundRecord alloc] init];
    }
    return self;
}

#pragma mark - 录音

// 开始录音
- (void)startRecord {
    [self.soundRecord startRecord];
}

// 开始一个时间限制的录音
- (void)startRecordWithLimitDuration:(NSTimeInterval)limitSeconds {
    self.soundRecord.limitRecordDuration = limitSeconds;
    [self.soundRecord startRecord];
}

// 完成录音
- (void)finishRecord {
    [self.soundRecord finishRecord];
}

// 取消录音
- (void)cancelCurrentRecord {
    [self.soundRecord cancelRecord];
}

#pragma mark - 播放

// 播放一个音频文件
- (void)playSoundModel:(LJSoundModel *)soundModel {
    [self.soundPlayer playSoundModel:soundModel];
}

// 停止播放 
- (void)stopPlayCurrentAudio {
    [self.soundPlayer stop];
}

// 暂停播放 
- (void)pausePlayCurrentAudio {
    [self.soundPlayer pause];
}

// 继续当前播放 
- (void)startPlayFromLastStopTimestamp {
    [self.soundPlayer play];
}

@end
