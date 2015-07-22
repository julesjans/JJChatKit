//
//  JJBubble.h
//  JJChatKit
//
//  Created by Julian Jans on 23/07/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJChatViewController.h"

#define BUBBLE_PADDING 8.0 // Padding used for the text etc within the bubble
#define BUBBLE_FACTOR 12.0 // Used for the corner-radius and the related size of the message tail

typedef enum : NSUInteger {
    BubbleLeft,
    BubbleRight,
} BubblePosition;


@interface JJBubble : UIView

/// A hold on the controller to get the colors etc...
@property (nonatomic, weak) JJChatViewController *controller;

/// The position of the bubble relative to whether the message is the recipient
@property (nonatomic, assign) BubblePosition bubblePosition;

@end