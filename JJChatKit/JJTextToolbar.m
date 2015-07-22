//
//  TextToolbar.m
//  Petsy
//
//  Created by Julian Jans on 14/01/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

#import "JJTextToolbar.h"
#import "JJChatAppearance.h"

@interface JJTextToolbar ()

@property (nonatomic) CGFloat desiredHeight;
@property (nonatomic, strong) CALayer *topBorder;

@end


#define TOTAL_HEIGHT 49.0f
#define TOTAL_VERTICAL_PADDING 16.0f
#define MAGIC_NUMBER 13.0f


@implementation JJTextToolbar


#pragma mark - View Lifecycle

- (void)awakeFromNib {
 
    [super awakeFromNib];
    [self configureView];
}

- (void)configureView
{
    self.backgroundColor = [[JJChatAppearance sharedApearance] inputViewColor];
    self.clipsToBounds = YES;
    
    if (!self.topBorder) {
        self.topBorder = [CALayer layer];
        self.topBorder.backgroundColor = [[JJChatAppearance sharedApearance] inputViewBorderColor].CGColor;
        self.topBorder.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 1);
        [self.layer addSublayer:self.topBorder];
    }
    
    [self.postButton setTintColor:[[JJChatAppearance sharedApearance] sendButtonColor]];
    
    self.textView.contentInset = UIEdgeInsetsMake(-1, 0, -6, 0);
    
    [self.textView.layer setCornerRadius:6.0];
    
    [self setHeight:TOTAL_HEIGHT];
}




- (void)setDelegate:(JJChatViewController *)delegate
{
    _delegate = delegate;
    self.backgroundColor = [[JJChatAppearance sharedApearance] inputViewColor];
    [self.postButton setTintColor:[[JJChatAppearance sharedApearance] sendButtonColor]];
    self.topBorder.backgroundColor = [[JJChatAppearance sharedApearance] inputViewBorderColor].CGColor;
}


#pragma mark - View attributes

- (void)setFont:(UIFont *)font
{
    self.textView.font = font;

    // TODO: This needs to be implemented to make the textview resize when a new font is selected:
    // [self setHeight:floor(((font.ascender + font.lineHeight) + 16 ) - 7)];
}

- (void)setHeight:(CGFloat)height
{
    _desiredHeight = height;
    
    [self setNeedsUpdateConstraints];
}

- (void)setOptimisedHeight
{
    if ([self.textView.text isEqualToString:@""]) {
        [self.textView setContentSize:CGSizeMake(self.textView.contentSize.width, TOTAL_HEIGHT - MAGIC_NUMBER)];
    }
    
    [self setHeight:MIN(self.textView.contentSize.height + MAGIC_NUMBER, 160)];
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    // TODO: This is a little brittle, and relies on the OS too much.
    // Need to do a check that this is an auto layout constraint
    NSLayoutConstraint *constraint = (NSLayoutConstraint *)[self.constraints lastObject];
    constraint.constant = self.desiredHeight;
}


#pragma mark - Actions

- (IBAction)didPostMessage:(id)sender
{
    [self.delegate didSendMessage:self.textView.text];
}

@end