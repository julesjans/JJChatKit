//
//  TextToolbar.m
//  Petsy
//
//  Created by Julian Jans on 14/01/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

#import "TextToolbar.h"
#import "UIColor+JJChatKit.h"

@interface TextToolbar ()

@property (nonatomic) CGFloat desiredHeight;

@end


@implementation TextToolbar

- (void)awakeFromNib {
 
    [super awakeFromNib];

    [self.postButton setTintColor:[UIColor toBackgroundColour]];

    [self.textView setContentInset:UIEdgeInsetsZero];
    
   

    
    [self setHeight:66];
    
    
//    [self setHeight:self.textView.contentSize.height + 16 + self.textView.textContainerInset.top + self.textView.textContainerInset.bottom];

    
    self.backgroundColor = [UIColor lightGrayColor];
}

- (void)setHeight:(CGFloat)height
{
    _desiredHeight = height;
    
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    
    
    
    
    
    NSLayoutConstraint *constraint = (NSLayoutConstraint *)[self.constraints lastObject];
    
    
    constraint.constant = self.desiredHeight;
    
    
}


@end




















