//
//  JJBubble.m
//  JJChatKit
//
//  Created by Julian Jans on 23/07/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

#import "JJBubble.h"
#import "UIColor+JJChatKit.h"


@interface JJBubble()

@property (nonatomic, assign) BubblePosition bubblePosition;

@end


@implementation JJBubble


- (instancetype)initWithFrame:(CGRect)frame position:(BubblePosition)position
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bubblePosition = position;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path;
    
    switch (self.bubblePosition) {
        case BubbleLeft:
            [[UIColor fromBackgroundColour] setFill];
            path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight) cornerRadii:CGSizeMake(12.0, 12.0)];
            break;
        case BubbleRight:
            [[UIColor toBackgroundColour] setFill];
            path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft) cornerRadii:CGSizeMake(12.0, 12.0)];
            break;
        default:
            break;
    }
    [path fill];
    
    // TODO: Draw the bubble point in here...
}

@end
