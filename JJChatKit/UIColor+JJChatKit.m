//
//  UIColor+JJChatKit.m
//  JJChatKit
//
//  Created by Julian Jans on 23/07/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

#import "UIColor+JJChatKit.h"

@implementation UIColor (JJChatKit)

+ (UIColor *)fromBackgroundColour {
    return [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
}

+ (UIColor *)fromTextColour {
    return [UIColor blackColor];
}

+ (UIColor *)toBackgroundColour {
//    return [UIColor colorWithRed:255/255.0 green:240/255.0 blue:239/255.0 alpha:1.0];
    return [UIColor colorWithRed:79/255.0 green:240/255.0 blue:87/255.0 alpha:1.0];
}

+ (UIColor *)toTextColour {
    return [UIColor whiteColor];
}

@end