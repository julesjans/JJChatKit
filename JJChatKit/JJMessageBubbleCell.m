/*
 
 WMMessageBubbleCell.m
 VoiceCandy
 
 Chat View Message Bubble
 
 Copyright 2014 Yousoft Ltd. All rights reserved.
 
*/


#import "JJMessageBubbleCell.h"
//#import "ActionButton.h"
#import "NSDate+Conversions.h"
#import "UIColor+JJChatKit.h"


#define FRAME_PADDING 10.0
#define BUBBLE_CORNER_RADIUS 12.0


@interface JJMessageBubbleCell ()

@property (nonatomic, strong) UIView *bubbleView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *timeStampLabel;
@property (nonatomic, strong) UIImageView *bubblePoint;
@property (nonatomic) BOOL recipient;

@end


@implementation JJMessageBubbleCell


#pragma mark - View Layout

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self clearBubble];
}

- (void)clearBubble
{
    if (self.bubbleView) {
        [self.bubbleView removeFromSuperview];
        self.bubbleView = nil;
    }
    if (self.messageLabel) {
        [self.messageLabel removeFromSuperview];
        self.messageLabel = nil;
    }
    if (self.timeStampLabel) {
        [self.timeStampLabel removeFromSuperview];
        self.timeStampLabel = nil;
    }
}

- (UILabel *)messageLabel
{
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _messageLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0];
        _messageLabel.userInteractionEnabled = YES;
    }
    return _messageLabel;
}

- (UIView *)bubbleView
{
    if (!_bubbleView) {
        _bubbleView = [[UIView alloc] initWithFrame:CGRectZero];
        _bubbleView.translatesAutoresizingMaskIntoConstraints = NO;
        _bubbleView.layer.cornerRadius = BUBBLE_CORNER_RADIUS;
    }
    return _bubbleView;
}

- (UILabel *)timeStampLabel
{
    if (!_timeStampLabel) {
        _timeStampLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeStampLabel.textColor = [UIColor lightGrayColor];
        _timeStampLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:11.0];
    }
    return _timeStampLabel;
}

- (UIImageView *)bubblePoint
{
    if (!_bubblePoint) {
        _bubblePoint = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BUBBLE_CORNER_RADIUS, BUBBLE_CORNER_RADIUS)];
        _bubblePoint.clipsToBounds = NO;
    }
    return _bubblePoint;
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
    if (self.recipient) {
        [self.bubbleView setBackgroundColor:[UIColor fromBackgroundColour]];
        [self.messageLabel setTextColor:[UIColor fromTextColour]];
        [self.messageLabel setTextAlignment:NSTextAlignmentLeft];
    } else {
        [self.bubbleView setBackgroundColor:[UIColor toBackgroundColour]];
        [self.messageLabel setTextColor:[UIColor toTextColour]];
        [self.messageLabel setTextAlignment:NSTextAlignmentRight];
    }
    
    // Put in the message
    [self.messageLabel setText: [message valueForKey:@"content"]];
    [self.messageLabel setNumberOfLines:0];
    [self.messageLabel setLineBreakMode:NSLineBreakByWordWrapping];
    
    // Add the views
    [self.bubbleView addSubview:self.messageLabel];
    [self addSubview:self.bubbleView];
    
    // Set the constraints on the subviews
    [self.bubbleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[messageLabel]-8-|" options:0 metrics:nil views:@{@"messageLabel": self.messageLabel}]];
    [self.bubbleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[messageLabel]-8-|" options:0 metrics:nil views:@{@"messageLabel": self.messageLabel}]];
    
    if (self.recipient) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[bubbleView(<=width)]" options:0 metrics:@{@"width":@(self.frame.size.width * 0.75)} views:@{@"bubbleView": self.bubbleView}]];
    } else {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[bubbleView(<=width)]-8-|" options:0 metrics:@{@"width":@(self.frame.size.width * 0.75)} views:@{@"bubbleView": self.bubbleView}]];
    }
    

    

    
    
    
#pragma mark - Add autolayout to the bubble points!

//    CGRect bubbleFrame = self.bubblePoint.bounds;
//    if (self.recipient) {
//        bubbleFrame.origin.y = self.bubbleView.bounds.size.height - BUBBLE_CORNER_RADIUS;
//        [_bubblePoint setContentMode:UIViewContentModeBottomRight];
//        [self.bubblePoint setTintColor:[UIColor fromBackgroundColour]];
//        [self.bubblePoint setImage:[[UIImage imageNamed:@"bubble-left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
//    } else {
//        bubbleFrame.origin.x = self.bubbleView.bounds.size.width - BUBBLE_CORNER_RADIUS;
//        bubbleFrame.origin.y = self.bubbleView.bounds.size.height - BUBBLE_CORNER_RADIUS;
//        [_bubblePoint setContentMode:UIViewContentModeBottomLeft];
//        [self.bubblePoint setTintColor:[UIColor toBackgroundColour]];
//        [self.bubblePoint setImage:[[UIImage imageNamed:@"bubble-right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
//    }
//    [self.bubblePoint setFrame:bubbleFrame];
//    [self.bubbleView addSubview:self.bubblePoint];
    

#pragma mark - Handle the timestamps and the associated views.
    
    // Handle the time label at the bottom
//    NSString *dateString = [NSDate messageTimeString:[message valueForKey:@"createdAt"]];
//    [self.timeStampLabel setText:(dateString ? dateString : @"")];
//    [self.timeStampLabel sizeToFit];
//    
//    
//    CGFloat screenSize = [[UIScreen mainScreen] bounds].size.width;
//    
//    // If the message is ours put it over to the right
//    CGRect timeStampFrame = self.timeStampLabel.frame;
//    timeStampFrame.origin.x = (self.recipient ? 16 : (((screenSize) -  timeStampFrame.size.width) - 16));
//    timeStampFrame.origin.y = 12 + self.bubbleView.frame.size.height;
//    self.timeStampLabel.frame = timeStampFrame;
//    [self addSubview:self.timeStampLabel];
//
//    CGRect cellFrame = self.frame;
//    cellFrame.size.height = self.bubbleView.bounds.size.height + ((self.timeStampLabel.bounds.size.height * 1.2) + 10);
//    cellFrame.size.width = [[UIScreen mainScreen] bounds].size.width;
//    self.frame = cellFrame;
    
    
}


@end
