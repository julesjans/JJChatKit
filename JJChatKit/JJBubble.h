//
//  JJBubble.h
//  JJChatKit
//
//  Created by Julian Jans on 23/07/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum : NSUInteger {
    BubbleLeft,
    BubbleRight,
} BubblePosition;


@interface JJBubble : UIView

/// Designated initializer
- (instancetype)initWithFrame:(CGRect)frame position:(BubblePosition)position;

@end