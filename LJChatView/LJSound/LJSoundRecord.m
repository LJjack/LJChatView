//
//  LJSoundRecord.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/21.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJSoundRecord.h"

#import <AVFoundation/AVFoundation.h>

#import "NSString+LJFile.h"

#import "LJSoundModel.h"

@interface LJSoundRecord ()<AVAudioRecorderDelegate>

@property (nonatomic, strong) AVAudioRecorder *audioRecord;

@property (nonatomic, copy) NSDictionary *audioRecordSetting;

/* 当前只会有一个文件在录制 */
@property (nonatomic, strong) LJSoundModel *currentSoundModel;

@property (nonatomic, strong) NSTimer *soundMouterTimer;

@property (nonatomic, assign) NSTimeInterval recordProgress;

@end

@implementation LJSoundRecord


- (void)dealloc {
    if (self.soundMouterTimer) {
        [self.soundMouterTimer invalidate];
    }
}

- (instancetype)init {
    if (self = [super init]) {
        
        // 默认无录音时间限制
        self.limitRecordDuration = 0;
    }
    return self;
}

/* 获取当前录制音频文件*/
- (LJSoundModel*)getCurrentRecordSoundModel {
    return self.currentSoundModel;
}

- (void)createRecord {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    [audioSession setActive:YES error:nil];
    
    /* 阻止快速重复录音 */
    if (self.audioRecord.isRecording) {
        NSError *faildError = [NSError errorWithDomain:@"gjcf.AudioManager.com" code:-236 userInfo:@{@"msg": @"LJSoundRecord 正在录音"}];
        if (self.delegate && [self.delegate respondsToSelector:@selector(soundRecord:didOccusError:)]) {
            [self.delegate soundRecord:self didOccusError:faildError];
        }
        return;
    }
    
    if (self.currentSoundModel) {
        self.currentSoundModel = nil;
    }
    
    /* 置空Timer */
    if (self.soundMouterTimer) {
        [self.soundMouterTimer invalidate];
        self.soundMouterTimer = nil;
    }
    
    /* 创建一个新得录制文件 */
    self.currentSoundModel = [[LJSoundModel alloc]init];
    
    /* 设置新得录音文件得本地缓存地址 */

    
    /* 开始新的录音实例 */
    if (self.audioRecord) {
        if (self.audioRecord.isRecording) {
            [self.audioRecord stop];
            [self.audioRecord deleteRecording];
        }
        self.audioRecord = nil;
    }
    
    NSString *strUrl = [NSString stringWithFormat:@"%@/%@.mp4", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject], [NSString lj_uuid]];
    NSURL *url = [NSURL fileURLWithPath:strUrl];
    self.currentSoundModel.path = strUrl;
    NSError *createRecordError = nil;
    self.audioRecord = [[AVAudioRecorder alloc] initWithURL:url settings:self.audioRecordSetting error:&createRecordError];
    self.audioRecord.delegate = self;
    self.audioRecord.meteringEnabled = YES;
    if (createRecordError || ![self.audioRecord prepareToRecord]) {
        [self startRecordErrorDetail];
        return;
    }
    
    /* 创建输入音量更新 */
    self.soundMouterTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(updateSoundMouter:) userInfo:nil repeats:YES];
    [self.soundMouterTimer fire];
}

#pragma mark - 录音错误处理
- (void)startRecordErrorDetail {
    NSError *faildError = [NSError errorWithDomain:@"gjcf.AudioManager.com" code:-238 userInfo:@{@"msg": @"LJSoundRecord启动录音失败"}];
    if (self.delegate && [self.delegate respondsToSelector:@selector(soundRecord:didOccusError:)]) {
        [self.delegate soundRecord:self didOccusError:faildError];
    }
    
    /* 停止更新 */
    if (self.soundMouterTimer) {
        [self.soundMouterTimer invalidate];
        self.soundMouterTimer = nil;
    }
}

#pragma mark - 录音动作
- (void)startRecord {
    /* 是否支持录音 */
    [self createRecord];
    
    if (self.limitRecordDuration > 0) {
        _isRecording = [self.audioRecord recordForDuration:self.limitRecordDuration];
        
        if (_isRecording) {
            NSLog(@"录音限制 成功");
        } else {
            [self startRecordErrorDetail];
            NSLog(@"录音限制 失败");
        }
        
        return;
    }
    _isRecording = [self.audioRecord record];
    
    if (_isRecording) {
        NSLog(@"开始录音");
    } else {
        [self startRecordErrorDetail];
        NSLog(@"开始录音 失败");
    }
}

- (void)updateSoundMouter:(NSTimer *)timer {
    
    [self.audioRecord updateMeters];
    
    float soundLoudly = [self.audioRecord peakPowerForChannel:0];
    _soundMouter = pow(10, (0.05 * soundLoudly));
    
    NSLog(@"audio soundMouter :%f",_soundMouter);
    
    if ([self.delegate respondsToSelector:@selector(soundRecord:soundMeter:)]) {
        [self.delegate soundRecord:self soundMeter:_soundMouter];
    }
    
    /* 录音完成或者停止得时候拿不到这个时间 */
    self.currentSoundModel.second = self.audioRecord.currentTime;
    
    /* 限制录音时间观察进度 */
    if (self.limitRecordDuration > 0) {
        
        self.recordProgress = self.audioRecord.currentTime;
        
        if ([self.delegate respondsToSelector:@selector(soundRecord:limitDurationProgress:)]) {
            [self.delegate soundRecord:self limitDurationProgress:self.recordProgress];
        }
        
        if (self.audioRecord.currentTime >= self.limitRecordDuration) {
            [self finishRecord];
            return;
        }
    }
}

- (void)finishRecord {
    if ([self.audioRecord isRecording]) {
        [self.audioRecord stop];
        _isRecording = NO;
    }
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
    [audioSession setActive:NO error:nil];
}

- (void)cancelRecord {
    if (!self.audioRecord) return;
    if (!_isRecording) return;
    
    [self.audioRecord stop];
    _isRecording = NO;
    self.currentSoundModel = nil;
    [self.audioRecord deleteRecording];
    
    if ([self.delegate respondsToSelector:@selector(soundRecordDidCancel:)]) {
        
        [self.delegate soundRecordDidCancel:self];
    }
}

#pragma mark - AVAudioRecorder Delegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    /* 停止timer */
    if (self.soundMouterTimer) {
        [self.soundMouterTimer invalidate];
        self.soundMouterTimer = nil;
    }
    
    if (flag) {
        
        /* 如果录音时间小于最小要求时间 */
        if (self.recordProgress < self.minEffectDuration) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(soundRecord:didFaildByMinRecordDuration:)]) {
                [self.delegate soundRecord:self didFaildByMinRecordDuration:self.minEffectDuration];
                _isRecording = NO;
            }
            
            return;
        }
        
        /* 完成录制 */
        if ([self.delegate respondsToSelector:@selector(soundRecord:finishRecord:)]) {
            _isRecording = NO;
            if (self.currentSoundModel) {
                self.currentSoundModel.data = [NSData dataWithContentsOfURL:recorder.url];
                [self.delegate soundRecord:self finishRecord:self.currentSoundModel];
            } else {
                if ([self.delegate respondsToSelector:@selector(soundRecordDidCancel:)]) {
                    [self.delegate soundRecordDidCancel:self];
                }
            }
        }
        
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(soundRecord:didOccusError:)]) {
        _isRecording = NO;
        [self.delegate soundRecord:self didOccusError:error];
    }
}

#pragma mark - Getters

- (NSDictionary *)audioRecordSetting {
    if (!_audioRecordSetting) {
        //录音设置
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc]init];
        //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
        [recordSetting setValue:[NSNumber numberWithFloat:8000] forKey:AVSampleRateKey];
        //录音通道数  1 或 2
        [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
        //线性采样位数  8、16、24、32
        [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        //录音的质量
        [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
        
        _audioRecordSetting = recordSetting.copy;
    }
    return _audioRecordSetting;
}

@end
