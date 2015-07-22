//
//  JJCollectionViewCell.h
//  JJChatKit
//
//  Created by Julian Jans on 23/07/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "JJChatViewController.h"
#import "JJMessage.h"

#define SIDE_PADDING 75

@interface JJCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) id<JJMessage> message;

// Where is this being set..?
@property (nonatomic) BOOL recipient;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *sidePadding;

@end