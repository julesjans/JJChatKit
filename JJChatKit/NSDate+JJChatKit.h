/*
 
 NSDate + Conversions.h
 VoiceCandy
 
 - Useful date conversion helpers
 
 Copyright 2014 Yousoft Ltd. All rights reserved.
 
 */


#import <Foundation/Foundation.h>


@interface NSDate (JJChatKit)

// Formats the date object into a readable string (UTC)
+ (NSString *)sentDateString:(NSDate *)date;

// Formats the date object into a readable string (UTC)
+ (NSString *)sentTimeString:(NSDate *)date;

@end