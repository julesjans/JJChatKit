//
//  AppDelegate.m
//  Chat App
//
//  Created by Julian Jans on 30/07/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

#import "AppDelegate.h"
#import <JJChatKit/JJChatKit.h>


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[JJChatAppearance appearance] setFromTextColor:[UIColor darkGrayColor]];
    
    return YES;
}

@end