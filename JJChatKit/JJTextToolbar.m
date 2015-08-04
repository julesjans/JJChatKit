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


@implementation JJTextToolbar

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

   
    [self setHeight:49];
}

- (void)setHeight:(CGFloat)height
{
    _desiredHeight = height;
    
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    #warning This is brittle, and relies on the OS
    // Need to do a check that this is an auto layout constraint
    NSLayoutConstraint *constraint = (NSLayoutConstraint *)[self.constraints lastObject];
    constraint.constant = self.desiredHeight;
}



@end