//
//  TextToolbar.h
//  Petsy
//
//  Created by Julian Jans on 14/01/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJChatViewController.h"

@interface JJTextToolbar : UIView

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UIButton *postButton;

// TODO: There is no protocol for this delegate!

// where is this being set..?
// Is this even needed..?
@property (nonatomic, weak) JJChatViewController *delegate;

- (void)setOptimisedHeight;
- (void)setHeight:(CGFloat)height;
- (void)setFont:(UIFont *)font;

@end