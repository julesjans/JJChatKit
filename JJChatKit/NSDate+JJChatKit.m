/*
 
 NSDate + Conversions.m
 VoiceCandy
 
 Copyright 2014 Yousoft Ltd. All rights reserved.
 
*/


#import "NSDate+JJChatKit.h"


@implementation NSDate (JJChatKit)


+ (NSDate *)dateFromServerDate:(NSString*)serverDate
{
    NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
    [inFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT]];
    [inFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
    [inFormat setDateFormat:@"YYYY-MM-dd'T'HH:mm:ss.SZZZ"];
    
    return [inFormat dateFromString:serverDate];
}

+ (NSString *)humanStringFromDate:(NSDate *)date
{
    NSDateFormatter *outFormat = [[NSDateFormatter alloc] init];
    [outFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT]];
    [outFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
    [outFormat setDateFormat:@"MMMM dd, yyyy"];
    
    return [outFormat stringFromDate:date];
}

+ (NSString *)birthdayStringFromDate:(NSDate *)date
{
    NSDateFormatter *outFormat = [[NSDateFormatter alloc] init];
    [outFormat setTimeZone:[NSTimeZone systemTimeZone]];
    [outFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
    [outFormat setDateFormat:@"YYYY-MM-dd"];
    
    return [outFormat stringFromDate:date];
}

+ (NSString *)messageTimeString:(NSDate *)date
{
    NSDateFormatter *outFormat = [[NSDateFormatter alloc] init];
    [outFormat setTimeZone:[NSTimeZone systemTimeZone]];
    [outFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
    [outFormat setDateFormat:@"EEE dd MMM, h:mm a"];
    
    return [outFormat stringFromDate:date];
}

- (NSDate *)dateYearsAgo:(NSUInteger)yearsAgo
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *addComponents = [[NSDateComponents alloc] init];
    addComponents.year = -yearsAgo;
    return [calendar dateByAddingComponents:addComponents toDate:self options:0];
}

@end