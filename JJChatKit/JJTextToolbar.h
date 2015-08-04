//
//  TextToolbar.h
//  Petsy
//
//  Created by Julian Jans on 14/01/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JJTextToolbar : UIView

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UIButton *postButton;

- (void)setHeight:(CGFloat)height;

@end