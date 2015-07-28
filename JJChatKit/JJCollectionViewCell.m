/*
 
 WMMessageBubbleCell.m
 VoiceCandy
 
 Chat View Message Bubble
 
 Copyright 2014 Yousoft Ltd. All rights reserved.
 
*/


#import "JJCollectionViewCell.h"
#import "UIColor+JJChatKit.h"
#import "JJBubble.h"



@interface JJCollectionViewCell ()

@property (nonatomic, strong) IBOutlet JJBubble *bubbleView;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;

@property (nonatomic) BOOL recipient;

@property (nonatomic, strong) NSArray *constraints;

@end


@implementation JJCollectionViewCell


#pragma mark - View Layout

//- (void)prepareForReuse
//{
//    [super prepareForReuse];
//    [self clearBubble];
//}

- (void)clearBubble
{
    if (!_bubbleView) {
        _bubbleView = [[JJBubble alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_bubbleView];
    }
    
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _messageLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0];
        _messageLabel.userInteractionEnabled = YES;
        
        [_messageLabel setNumberOfLines:0];
        [_messageLabel setLineBreakMode:NSLineBreakByWordWrapping];
        
        [_bubbleView addSubview:_messageLabel];
        [_bubbleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[messageLabel]-8-|" options:0 metrics:nil views:@{@"messageLabel": _messageLabel}]];
        [_bubbleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[messageLabel]-8-|" options:0 metrics:nil views:@{@"messageLabel": _messageLabel}]];
    }
}



#pragma mark - Setting the message view
- (void)setMessage:(id)message
{
    _message = message;

    
    // Reset all the views
    [self clearBubble];
    
    // Set whether we are the recipient of the message, will affect the view placement
    self.recipient = [[message valueForKeyPath:@"recipient"]  boolValue];
    
    // Set the initial colours of the bubble according to the recipient
    [self.messageLabel setTextColor:(self.recipient ? [UIColor fromTextColour] : [UIColor toTextColour])];
    [self.messageLabel setTextAlignment:(self.recipient ? NSTextAlignmentLeft : NSTextAlignmentRight)];
    [self.messageLabel setText:[message valueForKey:@"content"]];

    

    self.bubbleView.bubblePosition = self.recipient ? BubbleLeft : BubbleRight;
    
    // Side constraints for the bubble view
    NSString *visualFormat = self.recipient ? @"H:|-8-[bubbleView(<=width)]" : @"H:[bubbleView(<=width)]-8-|";
    
    
    
    
    
    [self removeConstraints:self.constraints];
    
    self.constraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormat options:0 metrics:@{@"width":@(self.frame.size.width * 0.75)} views:@{@"bubbleView": self.bubbleView}];
    
    [self addConstraints:self.constraints];
}





@end
