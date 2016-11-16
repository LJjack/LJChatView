//
//  LJSoundPlayer.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/21.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJSoundPlayer.h"

#import <AVFoundation/AVFoundation.h>

#import "LJSoundModel.h"

@interface LJSoundPlayer ()<AVAudioPlayerDelegate>

@property (nonatomic,strong)AVAudioPlayer *audioPlayer;

@property (nonatomic,strong)LJSoundModel *currentPlaySoundModel;

@property (nonatomic, assign) NSTimeInterval currentPlaySoundDuration;


@end

@implementation LJSoundPlayer

- (void)createPlayer {
    
    /* 没有可以播放的文件 */
    if (!self.currentPlaySoundModel) {
        
        NSError *faildError = [NSError errorWithDomain:@"gjcf.AudioManager.com" code:-235 userInfo:@{@"msg": @"LJSoundPlayer 正在播放失败"}];
        if (self.delegate && [self.delegate respondsToSelector:@selector(soundPlayer:didOccusError:)]) {
            [self.delegate soundPlayer:self didOccusError:faildError];
        }
        
        return;
    }
    
    /* 如果存在播放，那么停止播放 */
    if (self.audioPlayer && self.audioPlayer.isPlaying) {
        
        _isPlaying = NO;
        
        [self.audioPlayer stop];
        
        self.audioPlayer = nil;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    self.audioPlayer = [[AVAudioPlayer alloc]initWithData:self.currentPlaySoundModel.data error:nil];
    self.audioPlayer.delegate = self;
    /* 获取当前播放文件得时间总长度 */
    self.currentPlaySoundDuration = self.audioPlayer.duration;
    [self.audioPlayer prepareToPlay];
    _isPlaying = [self.audioPlayer play];
}

#pragma mark - 公开方法
- (void)playSoundModel:(LJSoundModel *)soundModel {
    
    if (self.currentPlaySoundModel) {
        self.currentPlaySoundModel = nil;
    }
    
    self.currentPlaySoundModel = soundModel;
    
    [self createPlayer];
}

- (LJSoundModel *)getCurrentPlayingSoundModel {
    
    return self.currentPlaySoundModel;
}

- (void)play {
    if (!self.audioPlayer) return;
    if (self.audioPlayer.isPlaying) return;
    _isPlaying = [self.audioPlayer play];
}

- (void)stop {
    if (!self.audioPlayer) return;
    if (!self.audioPlayer.isPlaying) return;
    [self.audioPlayer stop];
    _isPlaying = NO;
}

- (NSInteger)currentPlaySoundModelDuration {
    return self.currentPlaySoundDuration;
}

- (void)pause {
    if (!self.audioPlayer) return;
    if (!self.audioPlayer.isPlaying) return;
    [self.audioPlayer pause];
    _isPlaying = NO;
}


#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        _isPlaying = NO;
        /* 进度完成 */
        if (self.delegate && [self.delegate respondsToSelector:@selector(soundPlayer:didFinishPlayAudio:)]) {
            [self.delegate soundPlayer:self didFinishPlayAudio:self.currentPlaySoundModel];
        }
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(soundPlayer:didOccusError:)]) {
        [self.delegate soundPlayer:self didOccusError:error];
    }
    _isPlaying = NO;
}

@end
