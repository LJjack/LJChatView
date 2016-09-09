//
//  GJGCChatInputConst.m
//  GJGroupChat
//
//  Created by ZYVincent on 14-10-28.
//  Copyright (c) 2014年 ZYProSoft. All rights reserved.
//

#import "GJGCChatInputConst.h"

NSString *const GJGCChatInputTextViewRecordSoundMeterNoti = @"GJGCChatInputTextViewRecordSoundMeterNoti";

NSString *const GJGCChatInputTextViewRecordTooShortNoti = @"GJGCChatInputTextViewRecordTooShortNoti";

NSString *const GJGCChatInputTextViewRecordTooLongNoti = @"GJGCChatInputTextViewRecordTooLongNoti";

NSString *const GJGCChatInputExpandEmojiPanelChooseEmojiNoti = @"GJGCChatInputExpandEmojiPanelChooseEmojiNoti";

NSString *const GJGCChatInputExpandEmojiPanelChooseDeleteNoti = @"GJGcChatInputExpandEmojiPanelChooseDeleteNoti";

NSString *const GJGCChatInputExpandEmojiPanelChooseSendNoti = @"GJGcChatInputExpandEmojiPanelChooseSendNoti";

NSString *const GJGCChatInputSetLastMessageDraftNoti = @"GJGCChatInputSetLastMessageDraftNoti";

NSString *const GJGCChatInputPanelBeginRecordNoti = @"GJGCChatInputPanelBeginRecordNoti";

NSString *const GJGCChatInputPanelNeedAppendTextNoti = @"GJGCChatInputPanelNeedAppendTextNoti";

NSString *const GJGCChatInputExpandEmojiPanelChooseGIFEmojiNoti = @"GJGCChatInputExpandEmojiPanelChooseGIFEmojiNoti";

@implementation GJGCChatInputConst

+ (NSString *)panelNoti:(NSString *)notiName formateWithIdentifier:(NSString *)identifier
{
    if ([self stringIsNull:notiName]) {
        return nil;
    }
    
    if ([self stringIsNull:identifier]) {
        return nil;
    }
    
    return [NSString stringWithFormat:@"%@_%@",notiName,identifier];
}
+ (BOOL)stringIsNull:(NSString *)string
{
    if (![string isKindOfClass:[NSString class]]) {
        return YES;
    }
    
    if (!string || [string isKindOfClass:[NSNull class]] || string.length == 0 || [string isEqualToString:@""]) {
        return YES;
    }else{
        return NO;
    }
}
@end
