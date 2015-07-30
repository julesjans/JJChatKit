//
//  JJChatViewController.h
//  JJChatKit
//
//  Created by Julian Jans on 22/07/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJMessage.h"


@interface JJChatViewController : UIViewController

@property (nonatomic, strong) NSArray *messages;

@property (nonatomic, strong) UIFont *messageFont;

@end



#warning need to be able to set the configuration of the colours in this controller?