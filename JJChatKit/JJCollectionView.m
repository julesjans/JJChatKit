//
//  JJCollectionView.m
//  JJChatKit
//
//  Created by Julian Jans on 15/09/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

#import "JJCollectionView.h"

@interface JJCollectionView ()

@property (nonatomic, copy) void(^reloadBlock)(void);

@end

@implementation JJCollectionView

- (void)reloadData
{
    if (!self.isAnimating) {
        [super reloadData];
        self.reloadBlock = nil;
    } else {
        __weak JJCollectionView *weakSelf = self;
        self.reloadBlock = ^void (void) { [weakSelf reloadData]; };
    }
}

- (void)setIsAnimating:(BOOL)isAnimating
{
    _isAnimating = isAnimating;
    if (!isAnimating) {
        if (self.reloadBlock) { self.reloadBlock();};
    }
}

@end