//
//  JJFlowLayout.m
//  JJChatKit
//
//  Created by Julian Jans on 24/07/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

// Exploring Scroll Views in iOS 7
// https://developer.apple.com/videos/wwdc/2013/

// https://github.com/TeehanLax/UICollectionView-Spring-Demo/pull/3/files


#import "JJFlowLayout.h"

@interface JJFlowLayout ()

@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;

@property (nonatomic, strong) NSMutableSet *visibleIndexPathsSet;

@property (nonatomic, assign) CGFloat latestDelta;

@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;

@end

@implementation JJFlowLayout


- (instancetype)init
{
    if (!(self = [super init])) return nil;
    
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    
    self.visibleIndexPathsSet = [NSMutableSet set];
    
    return self;
}


- (void)prepareLayout
{
    [super prepareLayout];
    
    // Resets the behaviours if the orientation has changed
    if ([[UIApplication sharedApplication] statusBarOrientation] != self.interfaceOrientation) {
        [self.dynamicAnimator removeAllBehaviors];
        self.visibleIndexPathsSet = [NSMutableSet set];
    }
    self.interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    // Get a visible rect space to cover the view items that are on (or nearly on) screen
    CGRect originalRect = (CGRect){.origin = self.collectionView.bounds.origin, .size = self.collectionView.frame.size};
    CGRect visibleRect = CGRectInset(originalRect, -100, -100);

    // Get all the items in the contentView of the collection view
    NSArray *itemsInVisibleRectArray = [super layoutAttributesForElementsInRect:visibleRect];
    
    // Get a set of all the indexPaths
    NSSet *itemsIndexPathsInVisibleRectSet = [NSSet setWithArray:[itemsInVisibleRectArray valueForKey:@"indexPath"]];
    
    // Get an array of the behaviours that are off screen
    NSPredicate *notVisiblePredicate = [NSPredicate predicateWithBlock:^BOOL(UIAttachmentBehavior *behaviour, NSDictionary *bindings) {
        return [itemsIndexPathsInVisibleRectSet member:[[[behaviour items] firstObject] indexPath]] == nil;
    }];
    
    // And remove them from the animator, and from the visible indexPath set
    [[self.dynamicAnimator.behaviors filteredArrayUsingPredicate:notVisiblePredicate] enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        [self.dynamicAnimator removeBehavior:obj];
        [self.visibleIndexPathsSet removeObject:[[[obj items] firstObject] indexPath]];
    }];
    
    // Get an array of newly visible items that where not already in the visible array (don't add behaviours twice)
    NSPredicate *visiblePredicate = [NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *item, NSDictionary *bindings) {
        return [self.visibleIndexPathsSet member:item.indexPath] == nil;
    }];
    
    // And add the behaviours afresh
    [[itemsInVisibleRectArray filteredArrayUsingPredicate:visiblePredicate] enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *item, NSUInteger idx, BOOL *stop) {
    
        CGPoint center = item.center;
        UIAttachmentBehavior *springBehaviour = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:center];
        
        springBehaviour.length = 0.0f;
        springBehaviour.damping = 0.5f;
        springBehaviour.frequency = 0.8f;
        
        [self.dynamicAnimator addBehavior:springBehaviour];
        
        // Add the indexPath to the list of visible
        [self.visibleIndexPathsSet addObject:item.indexPath];
    }];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.dynamicAnimator itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    CGFloat delta = newBounds.origin.y - self.collectionView.bounds.origin.y;
    
    self.latestDelta = delta;
    
    [self.dynamicAnimator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger idx, BOOL *stop) {
        
        CGFloat yDistanceFromTouch = fabs(touchLocation.y - springBehaviour.anchorPoint.y);
        CGFloat scrollResistance = yDistanceFromTouch / 500;
        
        UICollectionViewLayoutAttributes *item = springBehaviour.items.firstObject;
        CGPoint center = item.center;
      
        center.y += self.latestDelta < 0 ? MAX(delta, delta*scrollResistance) : MIN(delta, delta*scrollResistance);
        
        item.center = center;
        
        [self.dynamicAnimator updateItemUsingCurrentState:item];
    }];
    
    return NO;
}

@end
