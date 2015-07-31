//
//  UIColor+JJChatKit.h
//  JJChatKit
//
//  Created by Julian Jans on 23/07/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (JJChatKit)

+ (UIColor *)fromBackgroundColour;

+ (UIColor *)fromTextColour;

+ (UIColor *)toBackgroundColour;

+ (UIColor *)toTextColour;

+ (UIColor *)inputViewColor;

+ (UIColor *)inputViewBorderColor;

@end
