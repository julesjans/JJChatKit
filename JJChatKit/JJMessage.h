//
//  JJMessage.h
//  JJChatKit
//
//  Created by Julian Jans on 23/07/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JJMessage <NSObject>

@property (nonatomic, readonly) NSString *content, *senderName;
@property (nonatomic, readonly) NSDate *sentDate;
@property (nonatomic, readonly) BOOL recipient, read;

@end