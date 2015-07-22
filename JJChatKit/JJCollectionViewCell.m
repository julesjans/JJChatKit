//
//  JJCollectionViewCell.m
//  JJChatKit
//
//  Created by Julian Jans on 23/07/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//


#import "JJCollectionViewCell.h"
#import "JJChatAppearance.h"
#import "NSDate+JJChatKit.h"
#import "JJBubble.h"


#define MAX_SCALE_OF_MESSAGE 0.55


@interface JJCollectionViewCell ()

@property (nonatomic, weak) IBOutlet JJBubble *bubbleView;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;

@property (nonatomic, strong) NSArray *alignmentConstraints;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leftTextPadding, *rightTextPadding;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *minWidth;

@end


@implementation JJCollectionViewCell


#pragma mark - Setting the message view
- (void)setMessage:(id<JJMessage>)message
{
    _message = message;

    // Set whether we are the recipient of the message, will affect the view placement
    self.recipient = message.recipient;
    
    // Set the initial colors of the bubble according to the recipient
    [self.messageLabel setFont:[[JJChatAppearance sharedApearance] messageFont]];
    [self.messageLabel setTextColor:(self.recipient ? [[JJChatAppearance sharedApearance] fromTextColor] : [[JJChatAppearance sharedApearance] toTextColor])];
    [self.messageLabel setTextAlignment:(self.recipient ? NSTextAlignmentLeft : NSTextAlignmentRight)];
    [self.messageLabel setText:message.content];
    [self.timeLabel setText:[NSDate sentDateString:message.sentDate]];
    [self.timeLabel setTextColor:[[JJChatAppearance sharedApearance] timeLabelColor]];

    self.minWidth.constant = BUBBLE_FACTOR;
    
    NSString *visualFormat;
    
    BubblePosition bubblePosition = self.recipient ? BubbleLeft : BubbleRight;
    
    switch (bubblePosition) {
        case BubbleLeft:
            
            visualFormat = @"H:|-8-[bubbleView(<=width)]";
            self.leftTextPadding.constant = BUBBLE_PADDING + BUBBLE_FACTOR;
            self.rightTextPadding.constant = BUBBLE_PADDING;
            
            break;
            
        case BubbleRight:
            
            visualFormat = @"H:[bubbleView(<=width)]-83-|";
            self.leftTextPadding.constant = BUBBLE_PADDING;
            self.rightTextPadding.constant = BUBBLE_PADDING + BUBBLE_FACTOR;
            
            break;
    }
    
    self.bubbleView.bubblePosition = bubblePosition;
    
    [self removeConstraints:self.alignmentConstraints];
    
    self.alignmentConstraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormat options:0 metrics:@{@"width":@(self.bounds.size.width * MAX_SCALE_OF_MESSAGE)} views:@{@"bubbleView": self.bubbleView}];
    
    [self addConstraints:self.alignmentConstraints];
}

@end