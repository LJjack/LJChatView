//
//  GJCFAudioPlayer.m
//  GJCommonFoundation
//
//  Created by ZYVincent on 14-9-16.
//  Copyright (c) 2014年 ZYProSoft. All rights reserved.
//

#import "GJCFAudioPlayer.h"

@interface GJCFAudioPlayer ()<AVAudioPlayerDelegate>

@property (nonatomic,strong)AVAudioPlayer *audioPlayer;

@property (nonatomic,strong)GJCFAudioModel *currentPlayAudioFile;

@property (nonatomic, assign) NSTimeInterval currentPlayAudioDuration;


@end

@implementation GJCFAudioPlayer



- (void)createPlayer
{
    
    /* 没有可以播放的文件 */
    if (!self.currentPlayAudioFile) {
        
        NSLog(@"GJCFAudioPlayer No File To Play");
        
        NSError *faildError = [NSError errorWithDomain:@"gjcf.AudioManager.com" code:-235 userInfo:@{@"msg": @"GJCFAuidoPlayer正在播放失败"}];
        if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayer:didOccusError:)]) {
            [self.delegate audioPlayer:self didOccusError:faildError];
        }
        
        return;
    }
    
    /* 如果存在播放，那么停止播放 */
    if (self.audioPlayer && self.audioPlayer.isPlaying) {
        
        _isPlaying = NO;
        
        [self.audioPlayer stop];
        
        self.audioPlayer = nil;
    }
    
    self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:self.currentPlayAudioFile.localStorePath] error:nil];
    self.audioPlayer.delegate = self;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    _isPlaying = [self.audioPlayer play];
    /* 获取当前播放文件得时间总长度 */
    self.currentPlayAudioDuration = [self getLocalWavFileDuration:self.currentPlayAudioFile.localStorePath];
    
}

#pragma mark - 公开方法
- (void)playAudioFile:(GJCFAudioModel *)audioFile
{
    
    if (self.currentPlayAudioFile) {
        self.currentPlayAudioFile = nil;
    }
    
    self.currentPlayAudioFile = audioFile;
    
    [self createPlayer];
}

- (GJCFAudioModel *)getCurrentPlayingAudioFile
{
    return self.currentPlayAudioFile;
}

- (void)play
{
    if (!self.audioPlayer) {
        return;
    }
    if (self.audioPlayer.isPlaying) {
        return;
    }
    [self.audioPlayer play];
    _isPlaying = YES;
    
}

- (void)stop
{
    if (!self.audioPlayer) {
        return;
    }
    if (!self.audioPlayer.isPlaying) {
        return;
    }
    [self.audioPlayer stop];
    _isPlaying = NO;
    
}

- (NSTimeInterval)getLocalWavFileDuration:(NSString *)audioPath
{
    if (!audioPath) {
        return 0;
    }
    
    AVURLAsset* audioAsset =[AVURLAsset assetWithURL:[NSURL fileURLWithPath:audioPath]];
    
    CMTime audioDuration = audioAsset.duration;
    
    return  CMTimeGetSeconds(audioDuration);
}

- (NSInteger)currentPlayAudioFileDuration
{
    return self.currentPlayAudioDuration;
}

- (NSString *)currentPlayAudioFileLocalPath
{
    return self.currentPlayAudioFile.localStorePath;
}

- (void)pause
{
    if (!self.audioPlayer) {
        return;
    }
    if (!self.audioPlayer.isPlaying) {
        return;
    }
    [self.audioPlayer pause];
    
    _isPlaying = NO;
}


#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag) {
        
        /* 进度完成 */
        if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayer:playingProgress:)]) {
                        
            [self.delegate audioPlayer:self playingProgress:1.f];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayer:didFinishPlayAudio:)]) {
            
            [self.delegate audioPlayer:self didFinishPlayAudio:self.currentPlayAudioFile];
            
            _isPlaying = NO;
            
        }
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayer:didOccusError:)]) {
        [self.delegate audioPlayer:self didOccusError:error];
    }
    _isPlaying = NO;
}

@end
