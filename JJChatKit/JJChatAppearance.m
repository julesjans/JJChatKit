//
//  JJChatAppearance.m
//  JJChatKit
//
//  Created by Julian Jans on 20/08/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

#import "JJChatAppearance.h"


@implementation JJChatAppearance

+ (instancetype)sharedApearance
{
    static JJChatAppearance *_sharedApearance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedApearance = [[JJChatAppearance alloc] init];
    });
    return _sharedApearance;
}

+ (instancetype)appearance
{
    return [JJChatAppearance sharedApearance];
}


#pragma mark - Attributes

- (UIFont *)messageFont {
    if (!_messageFont) {
        return [UIFont fontWithName:@"AvenirNext-Medium" size:16.0];
    }
    return _messageFont;
}

- (UIColor *)fromBackgroundColor {
    if (!_fromBackgroundColor) {
        return [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
    }
    return _fromBackgroundColor;
}

- (UIColor *)fromTextColor {
    if (!_fromTextColor) {
        return [UIColor whiteColor];
    }
    return _fromTextColor;
}

- (UIColor *)toBackgroundColor {
    if (!_toBackgroundColor) {
        return [UIColor colorWithRed:79/255.0 green:240/255.0 blue:87/255.0 alpha:1.0];
    }
    return _toBackgroundColor;
}

- (UIColor *)toTextColor {
    if (!_toTextColor) {
        return [UIColor whiteColor];
    }
    return _toTextColor;
}

- (UIColor *)inputViewColor {
    if (!_inputViewColor) {
        return [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
    }
    return _inputViewColor;
}

- (UIColor *)inputViewBorderColor {
    if (!_inputViewBorderColor) {
        return [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
    }
    return _inputViewBorderColor;
}

- (UIColor *)sendButtonColor {
    if (!_sendButtonColor) {
        return [UIColor redColor];
    }
    return _sendButtonColor;
}

- (UIColor *)timeLabelColor {
    if (!_timeLabelColor) {
        return [UIColor lightGrayColor];
    }
    return _timeLabelColor;
}

@end