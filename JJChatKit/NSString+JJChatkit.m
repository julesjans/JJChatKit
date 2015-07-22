//
//  NSString+JJChatkit.m
//  JJChatKit
//
//  Created by Julian Jans on 30/07/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

#import "NSString+JJChatkit.h"

@implementation NSString (JJChatkit)

- (NSString *)keyForOrientation
{
    return [NSString stringWithFormat:@"%ld-%@", (long)[[UIApplication sharedApplication] statusBarOrientation], self];
}

- (BOOL)validString
{
    return (self && ![[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]);
}

@end