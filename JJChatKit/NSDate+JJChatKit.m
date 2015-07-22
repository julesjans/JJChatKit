/*
 
 NSDate + Conversions.m
 VoiceCandy
 
 Copyright 2014 Yousoft Ltd. All rights reserved.
 
*/


#import "NSDate+JJChatKit.h"


@implementation NSDate (JJChatKit)


+ (NSString *)sentDateString:(NSDate *)date
{
    NSDateFormatter *outFormat = [[NSDateFormatter alloc] init];
    [outFormat setTimeZone:[NSTimeZone systemTimeZone]];
    [outFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
    [outFormat setDateFormat:@"EEE dd MMM\nh:mm a"];
    
    return [outFormat stringFromDate:date];
}

+ (NSString *)sentTimeString:(NSDate *)date
{
    NSDateFormatter *outFormat = [[NSDateFormatter alloc] init];
    [outFormat setTimeZone:[NSTimeZone systemTimeZone]];
    [outFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
    [outFormat setDateFormat:@"hh:mm"];
    
    return [outFormat stringFromDate:date];
}

@end