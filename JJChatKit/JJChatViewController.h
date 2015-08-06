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

/// The collection view
@property (nonatomic, strong) UICollectionView *collectionView;

/// The messages to be displayed, required. Must contain objects that conform to JJMessage protocol
@property (nonatomic, strong) NSArray *messages;

/// View formatting
@property (nonatomic, strong) UIFont *messageFont;
@property (nonatomic, strong) NSString *placeholderText;
@property (nonatomic, strong) UIColor *fromBackgroundColour;
@property (nonatomic, strong) UIColor *fromTextColour;
@property (nonatomic, strong) UIColor *toBackgroundColour;
@property (nonatomic, strong) UIColor *toTextColour;
@property (nonatomic, strong) UIColor *inputViewColour;
@property (nonatomic, strong) UIColor *inputViewBorderColour;
@property (nonatomic, strong) UIColor *sendButtonColour;

/// The action called when the message has been posted, call super to dismiss and clear the view
- (void)didSendMessage:(NSString *)message;

@end