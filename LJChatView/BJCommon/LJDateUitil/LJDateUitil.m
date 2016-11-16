//
//  LJDateUitil.m
//  BJTasty
//
//  Created by 刘俊杰 on 16/8/16.
//  Copyright © 2016年 BJ. All rights reserved.
//

#import "LJDateUitil.h"

@implementation LJDateUitil

+ (NSCalendar *)sharedCalendar {
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    [currentCalendar setTimeZone:[NSTimeZone systemTimeZone]];
    [currentCalendar setFirstWeekday:2];
    return currentCalendar;
}

+ (NSDateFormatter *)sharedDateFormatter {
    static NSDateFormatter *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[NSDateFormatter alloc]init];
    });
    return _instance;
}

+ (NSString *)detailTimeAgoString:(NSDate *)date {
    if (!date) return nil;
    
    long long timeNow = [date timeIntervalSince1970];
    NSCalendar * calendar=[LJDateUitil sharedCalendar];
    NSCalendarUnit unitFlags = NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitWeekOfMonth|NSCalendarUnitWeekday;
    NSDateComponents * component=[calendar components:unitFlags fromDate:date];
    
    NSInteger year=[component year];
    NSInteger month=[component month];
    NSInteger day=[component day];
    
    NSDate * today=[NSDate date];
    
    component=[calendar components:unitFlags fromDate:today];
    
    NSInteger t_year=[component year];
    
    NSString*string=nil;
    
    long long now = [today timeIntervalSince1970];
    
    long long  distance= now - timeNow;
    if(distance<60)
        string=@"刚刚";
    else if(distance<60*60)
        string=[NSString stringWithFormat:@"%lld分钟前",distance/60];
    else if(distance<60*60*24)
        string=[NSString stringWithFormat:@"%lld小时前",distance/60/60];
    else if(distance<60*60*24*7)
        string=[NSString stringWithFormat:@"%lld天前",distance/60/60/24];
    else if(year==t_year)
        string=[NSString stringWithFormat:@"%ld月%ld日",(long)month,(long)day];
    else
        string=[NSString stringWithFormat:@"%ld年%ld月%ld日",(long)year,(long)month,(long)day];
    
    return string;
}

+ (NSString *)detailTimeAgoStringByInterval:(long long)timeInterval {
    return [LJDateUitil detailTimeAgoString:[LJDateUitil dateFromTimeInterval:timeInterval]];
}

+ (NSUInteger)daysAgoFromNow:(NSDate *)date {
    if (!date) return NSIntegerMax;
    
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay
                                               fromDate:date
                                                 toDate:[NSDate date]
                                                options:0];
    return [components day];
}

+ (NSUInteger)daysAgoAgainstMidnight:(NSDate *)date {
    if (!date) return NSIntegerMax;
    
    NSDateFormatter *mdf = [[self class] sharedDateFormatter];
    [mdf setDateFormat:@"yyyy-MM-dd"];
    NSDate *midnight = [mdf dateFromString:[mdf stringFromDate:date]];
    return (NSUInteger)[midnight timeIntervalSinceNow] / (60*60*24) *-1;
}

+ (NSString *)stringDaysAgoAgainstMidnight:(BOOL)flag withDate:(NSDate *)date {
    
    
    
    NSUInteger daysAgo = (flag) ? [LJDateUitil daysAgoAgainstMidnight:date] : [LJDateUitil daysAgoFromNow:date];
    NSString *text = nil;
    if (daysAgo == 0) {
        NSCalendar * calendar=[LJDateUitil sharedCalendar];
        NSDateComponents * component=[calendar components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];
        NSInteger hour = [component hour];
        NSInteger minute = [component minute];
    
        text = [NSString stringWithFormat:@"%02ld:%02ld",(long)hour,(long)minute];
    } else if (daysAgo == 1) {
        text = @"昨天";
    } else if (daysAgo == 2) {
        text = @"前天";
    } else if (daysAgo >2 && daysAgo < 7) {
        text = [NSString stringWithFormat:@"%@天前", @(daysAgo)];
    } else {
        text = @"7天前";
    }
    return text;
}

+ (NSString *)stringDaysAgo:(NSDate *)date {
    if (!date) return nil;
    
    return [LJDateUitil stringDaysAgoAgainstMidnight:NO withDate:date];
}

/*
 * iOS中规定的就是周日为第一天，自己改变周一为第一天
 */
+ (NSUInteger)weekDay:(NSDate *)date {
    if (!date) return NSIntegerMax;
    
    NSDateComponents *weekdayComponents = [[LJDateUitil sharedCalendar] components:NSCalendarUnitWeekday fromDate:date];
    //我们的习惯是周一为第一天，那么我们改一下就OK了
    NSUInteger wDay = [weekdayComponents weekday];
    //将第一天设为周日
    if (wDay == 1) {
        wDay = 7;
    }else{
        wDay = wDay - 1;
    }
    return wDay;
}

+ (NSString *)weekDayString:(NSDate *)date {
    if (!date) return nil;
    
    NSDictionary *weekNameDict = @{
                                   @(1):@"一",
                                   @(2):@"二",
                                   @(3):@"三",
                                   @(4):@"四",
                                   @(5):@"五",
                                   @(6):@"六",
                                   @(7):@"日",
                                   };
    NSString *weekName = [weekNameDict objectForKey:@([LJDateUitil weekDay:date])];
    return [NSString stringWithFormat:@"星期%@",weekName];
}

+ (NSString *)weekOfYearNumberString:(NSDate *)date {
    if (!date) return nil;
    
    return [NSString stringWithFormat:@"第%@周",@([LJDateUitil weekOfYearNumber:date])];
}

+ (NSUInteger)weekOfYearNumber:(NSDate *)date {
    if (!date) return NSIntegerMax;
    
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitWeekOfYear fromDate:date];
    return [dateComponents weekOfYear];
}

+ (NSUInteger)hour:(NSDate *)date {
    if (!date) return NSIntegerMax;
    
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitHour fromDate:date];
    return [dateComponents hour];
}

+ (NSUInteger)minute:(NSDate *)date {
    if (!date) return NSIntegerMax;
    
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitMinute fromDate:date];
    return [dateComponents minute];
}

+ (NSUInteger)year:(NSDate *)date {
    if (!date) return NSIntegerMax;
    
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear fromDate:date];
    return [dateComponents year];
}

+ (NSUInteger)month:(NSDate *)date {
    if (!date) return NSIntegerMax;
    
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitMonth) fromDate:date];
    return [dateComponents month];
}

+ (NSInteger)day:(NSDate *)date {
    if (!date) return NSIntegerMax;
    
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitDay fromDate:date];
    return [dateComponents day];
}

+ (NSDate *)dateFromTimeInterval:(NSTimeInterval)timeInterval {
    return [NSDate dateWithTimeIntervalSince1970:timeInterval];
}

+ (NSDate *)dateFromString:(NSString *)string {
    if (!string || !string.length) return nil;
    
    return [LJDateUitil dateFromString:string withFormat:kNSDateHelperFormatSQLDate];
}

+ (NSDate *)dateTimeFromString:(NSString *)string {
    if (!string || !string.length) return nil;
    
    return [LJDateUitil dateFromString:string withFormat:kNSDateHelperFormatSQLDateWithTime];
}

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format {
    if ((!string || !string.length) || (!format || !format.length)) return nil;
    
    NSDateFormatter *formatter = [self sharedDateFormatter];
    [formatter setDateFormat:format];
    NSDate *date = [formatter dateFromString:string];
    return date;
}

+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)string {
    if (!date || (!string || !string.length)) return nil;
    
    [[[self class] sharedDateFormatter] setDateFormat:string];
    NSString *timestamp_str = [[[self class] sharedDateFormatter] stringFromDate:date];
    return timestamp_str;
}

+ (NSString *)stringFromDate:(NSDate *)date {
    if (!date) return nil;
    
    return [LJDateUitil stringFromDate:date withFormat:kNSDateHelperFormatSQLDateWithTime];
}

+ (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle
                        timeStyle:(NSDateFormatterStyle)timeStyle
                         withDate:(NSDate *)date {
    if (!date) return nil;
    
    [[[self class] sharedDateFormatter] setDateStyle:dateStyle];
    [[[self class] sharedDateFormatter] setTimeStyle:timeStyle];
    NSString *outputString = [[[self class] sharedDateFormatter] stringFromDate:date];
    return outputString;
}

+ (NSDate *)beginningOfWeek:(NSDate *)date {
    if (!date) return nil;
    
    // largely borrowed from "Date and Time Programming Guide for Cocoa"
    // we'll use the default calendar and hope for the best
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDate *beginningOfWeek = nil;
    BOOL ok = [calendar rangeOfUnit:NSCalendarUnitWeekOfYear startDate:&beginningOfWeek
                           interval:NULL forDate:date];
    if (ok) {
        return beginningOfWeek;
    }
    // couldn't calc via range, so try to grab Sunday, assuming gregorian style
    // Get the weekday component of the current date
    NSDateComponents *weekdayComponents = [calendar components:NSCalendarUnitWeekday fromDate:date];
    /*
     Create a date components to represent the number of days to subtract from the current date.
     The weekday value for Sunday in the Gregorian calendar is 1, so subtract 1 from the number of days to subtract from the date in question.  (If today's Sunday, subtract 0 days.)
     */
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay: 0 - ([weekdayComponents weekday] - 1)];
    beginningOfWeek = nil;
    beginningOfWeek = [calendar dateByAddingComponents:componentsToSubtract toDate:date options:0];
    
    //normalize to midnight, extract the year, month, and day components and create a new date from those components.
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:beginningOfWeek];
    return [calendar dateFromComponents:components];
    
}

+ (NSDate *)beginningOfDay:(NSDate *)date {
    if (!date) return nil;
    
    NSCalendar *calendar = [[self class] sharedCalendar];
    // Get the weekday component of the current date
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [calendar dateFromComponents:components];
}

+ (NSDate *)endOfWeek:(NSDate *)date {
    if (!date) return nil;
    
    NSCalendar *calendar = [LJDateUitil sharedCalendar];
    // Get the weekday component of the current date
    NSDateComponents *weekdayComponents = [calendar components:NSCalendarUnitWeekday fromDate:date];
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    // to get the end of week for a particular date, add (7 - weekday) days
    [componentsToAdd setDay:(7 - [weekdayComponents weekday])];
    NSDate *endOfWeek = [calendar dateByAddingComponents:componentsToAdd toDate:date options:0];
    
    return endOfWeek;
}

+ (NSString *)dateFormatString {
    return kNSDateHelperFormatSQLDate;
}

+ (NSString *)timeFormatString {
    return kNSDateHelperFormatSQLTime;
}

+ (NSString *)timestampFormatString {
    return kNSDateHelperFormatSQLDateWithTime;
}

+ (NSString *)dbFormatString {
    return kNSDateHelperFormatSQLDateWithTime;
}

+ (NSString *)birthdayToAge:(NSDate *)date {
    if (!date) return nil;
    
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date toDate:[NSDate date] options:0];
    
    if ([components year] > 0) {
        
        return [NSString stringWithFormat:@"%ld岁",(long)[components year]];
        
    }else if([components month] > 0) {
        
        return [NSString stringWithFormat:@"%ld个月%ld天",(long)[components month],(long)[components day]];
        
    }else{
        
        return [NSString stringWithFormat:@"%ld天",(long)[components day]];
        
    }
}

+ (NSString *)birthdayToAgeByTimeInterval:(NSTimeInterval)date {
    return [LJDateUitil birthdayToAge:[LJDateUitil dateFromTimeInterval:date]];
}

+ (NSString *)dateToConstellation:(NSDate *)date {
    NSInteger day = [LJDateUitil day:date];
    NSInteger month = [LJDateUitil month:date];
    
    if (day == NSNotFound || month == NSNotFound) return nil;
    
    NSArray *constellations = @[
                                @"水瓶座", @"双鱼座", @"白羊座", @"金牛座", @"双子座", @"巨蟹座",
                                @"狮子座", @"处女座", @"天秤座", @"天蝎座", @"射手座", @"摩羯座"
                                ];
    
    NSString *constellation = nil;
    if( day <= 22 ){
        if( 1 != month ){
            constellation = constellations[month - 2];
        }else{
            constellation = constellations[11];
        }
    }else{
        constellation = constellations[month - 1];
    }
    return constellation;
}

+ (NSString *)dateToConstellationByTimeInterval:(NSTimeInterval)date {
    return [LJDateUitil dateToConstellation:[LJDateUitil dateFromTimeInterval:date]];
}

@end
