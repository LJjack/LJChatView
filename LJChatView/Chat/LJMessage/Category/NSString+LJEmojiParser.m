//
//  NSString+LJEmojiParser.m
//  JSQMessages
//
//  Created by 刘俊杰 on 16/8/2.
//  Copyright © 2016年 Hexed Bits. All rights reserved.
//

#import "NSString+LJEmojiParser.h"
#import <UIKit/UIKit.h>

@implementation NSString (LJEmojiParser)

/* 表情解析方法 */
+ (void)parseEmoji:(NSMutableString *)originString withEmojiTempString:(NSMutableString *)tempString withResultArray:(NSMutableArray *)resultArray {
    if (!tempString) {
        tempString = [originString mutableCopy];
    }
    
    NSString *regex = @"\\[([\u4E00-\u9FA5OKN]{1,3})\\]";
    NSRegularExpression *emojiRegexExp = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *originResult = [emojiRegexExp firstMatchInString:originString options:NSMatchingReportCompletion range:NSMakeRange(0, originString.length)];
    NSTextCheckingResult *tempResult = [emojiRegexExp firstMatchInString:tempString options:NSMatchingReportCompletion range:NSMakeRange(0, tempString.length)];
    
    if (!resultArray) {
        resultArray = [NSMutableArray array];
    }
    
    /* 所有合法表情处理 */
    NSString *path = [[NSBundle mainBundle] pathForResource:@"emojiName" ofType:@"plist"];
    NSDictionary *emojiNameDict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    while (originResult) {
        
        /* 表情名字 */
        NSString *emoji = [originString substringWithRange:originResult.range];
        
        if ([emoji isEqualToString:@"xxxx"] || [emoji isEqualToString:@"xxx"] || [emoji isEqualToString:@"xxxxx"]) {
            break;
        }
        
        /* 真实占位 */
        NSRange emojiRange = originResult.range;
        
        /* 替换真实占位的表情为空格，取得空格占位 */
        NSRange replaceRange = NSMakeRange(tempResult.range.location, 1);
        
        /* 替换占位，寻找下一个 */
        [tempString replaceCharactersInRange:tempResult.range withString:@" "];
        
        if (originResult.range.length == 3) {
            [originString replaceCharactersInRange:originResult.range withString:@"xxx"];
        }
        if (originResult.range.length == 4) {
            [originString replaceCharactersInRange:originResult.range withString:@"xxxx"];
        }
        if (originResult.range.length == 5) {
            [originString replaceCharactersInRange:originResult.range withString:@"xxxxx"];
        }
        
        /* 如果是合法表情 */
        if ([emojiNameDict objectForKey:emoji]) {
            
            NSDictionary *item = @{@"emoji":emoji,@"origin":[NSValue valueWithRange:emojiRange],@"temp":[NSValue valueWithRange:replaceRange]};
            
            [resultArray addObject:item];
            
        }
        
        [self parseEmoji:originString withEmojiTempString:tempString withResultArray:resultArray];
        
    }
}

+ (NSAttributedString *)formateContent:(NSString *)comment {
    
     NSString *regex = @"\\[([\u4E00-\u9FA5OKN]{1,3})\\]";
     NSRange range = [comment rangeOfString:regex options:NSRegularExpressionSearch];
    
    if (!range.length) {
        NSMutableAttributedString *contentAttributedString = [[NSMutableAttributedString alloc]initWithString:comment attributes:[self attributes]];
        return contentAttributedString;
    }
    
    NSMutableString *originString = [NSMutableString stringWithString:comment];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"plist"];
    NSArray *emojiNameArray = [NSArray  arrayWithContentsOfFile:path];
    NSMutableDictionary *emojiDict = [NSMutableDictionary dictionary];
    for (NSDictionary *item in emojiNameArray) {
        [emojiDict addEntriesFromDictionary:item];
    }
    
    NSMutableArray *emojiArray = [NSMutableArray array];
    
    NSMutableString *copyOriginString = [NSMutableString stringWithString:comment];
    [self parseEmoji:copyOriginString withEmojiTempString:nil withResultArray:emojiArray];
    
    /* 将表情替换成空格 */
    for (NSDictionary *emojiItem in emojiArray) {
        NSString *emoji = [emojiItem objectForKey:@"emoji"];
        [originString replaceOccurrencesOfString:emoji withString:@"\uFFFC" options:NSCaseInsensitiveSearch range:NSMakeRange(0, originString.length)];
    }
    
    NSMutableAttributedString *contentAttributedString = [[NSMutableAttributedString alloc]initWithString:originString attributes:[self attributes]];

    for (NSDictionary *emojiItem in emojiArray) {
        NSString *emoji = [emojiItem objectForKey:@"emoji"];
        NSRange tempRange = [[emojiItem objectForKey:@"temp"] rangeValue];
        
        /* 插入图片 */
        NSTextAttachment *attach = [[NSTextAttachment alloc] init];
        NSString *emojiIcon = [emojiDict objectForKey:emoji];
        UIImage *emojiImg = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",emojiIcon]];
        attach.image = emojiImg;
        attach.bounds = (CGRect){{0,-5}, emojiImg.size};
        
        /* 替换表情 */
        NSAttributedString *imageString = [NSAttributedString attributedStringWithAttachment:attach];
        [contentAttributedString replaceCharactersInRange:tempRange withAttributedString:imageString];
    }
    
    return contentAttributedString;
    
}

+ (NSDictionary *)attributes {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    //    paragraphStyle.maximumLineHeight = 3.0f;
    //    paragraphStyle.minimumLineHeight = 3.0f;
    return @{
             NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody],
             NSForegroundColorAttributeName:[UIColor whiteColor],
             NSParagraphStyleAttributeName :  paragraphStyle
             };
}

@end
