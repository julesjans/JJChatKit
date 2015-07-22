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

/// The collection view TODO: Is this only here to set the background of the collection view?
@property (nonatomic, strong, readonly) UICollectionView *collectionView;

/// The messages to be displayed, required. Must contain objects that conform to JJMessage protocol
@property (nonatomic, strong) NSArray *messages;

/// The action called when the message has been posted, call super to dismiss and clear the view
- (void)didSendMessage:(NSString *)message;

/// Reset the view to the last message
- (void)scrollToBottomAnimated:(BOOL)animated;

@end