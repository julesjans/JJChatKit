//
//  TextToolbar.m
//  Petsy
//
//  Created by Julian Jans on 14/01/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

#import "JJTextToolbar.h"
#import "UIColor+JJChatKit.h"

@interface JJTextToolbar ()

@property (nonatomic) CGFloat desiredHeight;

@end




#define TOTAL_HEIGHT 49.0f
#define TOTAL_VERTICAL_PADDING 16.0f
#define MAGIC_NUMBER 9.0f


@implementation JJTextToolbar

#pragma mark - View Lifecycle

- (void)awakeFromNib {
 
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor inputViewColor];
    self.clipsToBounds = YES;
    
    CALayer *rightBorder = [CALayer layer];
    rightBorder.backgroundColor = [UIColor inputViewBorderColor].CGColor;
    rightBorder.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 1);
    [self.layer addSublayer:rightBorder];
    
    [self.postButton setTintColor:[UIColor toBackgroundColour]];

    self.textView.contentInset = UIEdgeInsetsMake(-3, 0, -4, 0);
    
    [self.textView.layer setCornerRadius:6.0];

    [self setHeight:TOTAL_HEIGHT];
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
    
    #warning This is brittle, and relies on the OS
    // Need to do a check that this is an auto layout constraint
    NSLayoutConstraint *constraint = (NSLayoutConstraint *)[self.constraints lastObject];
    constraint.constant = self.desiredHeight;
}


#pragma mark - Actions

- (IBAction)didPostMessage:(id)sender
{
    [self.delegate didPostMessage:self.textView.text];
}

@end