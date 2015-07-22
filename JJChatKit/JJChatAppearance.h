//
//  JJChatAppearance.h
//  JJChatKit
//
//  Created by Julian Jans on 20/08/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JJChatAppearance : UIView <UIAppearance>

@property (nonatomic, strong) NSString *placeholderText        UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont  *messageFont             UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *fromBackgroundColor     UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *fromTextColor           UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *toBackgroundColor       UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *toTextColor             UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *inputViewColor          UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *inputViewBorderColor    UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *sendButtonColor         UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *timeLabelColor          UI_APPEARANCE_SELECTOR;

+ (instancetype)sharedApearance;

@end