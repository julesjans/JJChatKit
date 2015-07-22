//
//  ViewController.m
//  Chat App
//
//  Created by Julian Jans on 30/07/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

#import "ViewController.h"
#import "TestMessage.h"

#define AUTO_CREATE_MESSAGES true
#define RELOAD_REPEAT_TIMER 3.0f


@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up some test messages
    if (!self.messages) {
        NSMutableArray *array = [[NSMutableArray alloc]init];
        int x=0;
        while (x < 200) {
            [array addObject:[self createTestMessage]];
            x++;
        }
        self.messages = array;
    }
}


#pragma mark - Handle some dummy data

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    #if AUTO_CREATE_MESSAGES
    [self performSelector:@selector(recursiveLoad) withObject:nil];
    #endif
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(recursiveLoad) object:nil];
}

- (void)recursiveLoad
{
    NSMutableArray *array = [self.messages mutableCopy];
    [array addObject:[self createTestMessage]];
    self.messages = array;
    
    [self.collectionView reloadData];
    [self scrollToBottomAnimated:YES];
    
    [self performSelector:@selector(recursiveLoad) withObject:nil afterDelay:RELOAD_REPEAT_TIMER];
}


#pragma mark - Call back for posting a message

- (void)didSendMessage:(NSString *)message
{
    NSMutableArray *array = [self.messages mutableCopy];
    [array addObject:[self createTestMessage]];
    self.messages = array;
    
    [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0]]];
    [super didSendMessage:message];
}


#pragma mark - Messages

- (TestMessage *)createTestMessage
{
    TestMessage *message = [[TestMessage alloc] init];
    message.content = [self randomStringWithLength:arc4random_uniform(30)];
    message.recipient = [@((arc4random() % 2 ? 1 : 0)) boolValue];
    message.read = NO;
    message.sentDate = [NSDate date];
    return message;
}

- (NSString *)randomStringWithLength:(int)length {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: length];
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    for (int i=0; i<length; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((int)[letters length])]];
    }
    return randomString;
}

@end