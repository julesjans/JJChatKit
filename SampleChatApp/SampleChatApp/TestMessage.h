//
//  Message.h
//  Chat App
//
//  Created by Julian Jans on 30/07/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JJChatKit/JJChatKit.h>

@interface TestMessage : NSObject <JJMessage>

@property (nonatomic, strong) NSString *content, *senderName;

@property (nonatomic, strong) NSDate *sentDate;

@property (nonatomic, assign) BOOL recipient, read;

@end