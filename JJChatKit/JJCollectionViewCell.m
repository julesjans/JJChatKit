/*
 
 WMMessageBubbleCell.m
 VoiceCandy
 
 Chat View Message Bubble
 
 Copyright 2014 Yousoft Ltd. All rights reserved.
 
*/


#import "JJCollectionViewCell.h"
#import "UIColor+JJChatKit.h"
#import "JJBubble.h"


#define MAX_SCALE_OF_MESSAGE 0.75

@interface JJCollectionViewCell ()

@property (nonatomic, weak) IBOutlet JJBubble *bubbleView;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic) BOOL recipient;

@property (nonatomic, strong) NSArray *alignmentConstraints;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leftTextPadding, *rightTextPadding;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *minWidth;

@end


@implementation JJCollectionViewCell


#pragma mark - Setting the message view
- (void)setMessage:(id)message
{
    _message = message;

    // Set whether we are the recipient of the message, will affect the view placement
    self.recipient = [[message valueForKeyPath:@"recipient"]  boolValue];
    
    // Set the initial colours of the bubble according to the recipient
    [self.messageLabel setTextColor:(self.recipient ? [UIColor fromTextColour] : [UIColor toTextColour])];
    [self.messageLabel setTextAlignment:(self.recipient ? NSTextAlignmentLeft : NSTextAlignmentRight)];
    [self.messageLabel setText:[message valueForKey:@"content"]];
    
    
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
            
            visualFormat = @"H:[bubbleView(<=width)]-8-|";
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