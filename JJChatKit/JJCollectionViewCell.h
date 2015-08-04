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

@interface JJCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) id<JJMessage> message;

@property (nonatomic, weak) JJChatViewController *controller;

@end