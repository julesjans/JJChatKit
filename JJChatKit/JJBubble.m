//
//  JJBubble.m
//  JJChatKit
//
//  Created by Julian Jans on 23/07/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

#import "JJBubble.h"
#import "UIColor+JJChatKit.h"


@interface JJBubble ()

@property (nonatomic) CGRect drawBounds;

@end



@implementation JJBubble


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setBubblePosition:(BubblePosition)bubblePosition
{
    _bubblePosition = bubblePosition;
    [self setNeedsDisplay];
}

#define   DEGREES_TO_RADIANS(degrees)  ((M_PI * degrees)/ 180)

- (void)drawRect:(CGRect)rect
{
    switch (self.bubblePosition) {
        case BubbleLeft:
            [[UIColor fromBackgroundColour] setFill];
            
            // Transforms on the view for the right hand side
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            CGContextTranslateCTM(ctx, self.bounds.size.width, 0);
            CGContextScaleCTM(ctx, -1.0, 1.0);
            UIGraphicsPushContext(ctx);
            
            break;
        case BubbleRight:
            [[UIColor toBackgroundColour] setFill];
            break;
        default:
            break;
    }
    

    CGRect drawingRect;
    
    drawingRect = CGRectMake(0, 0, BUBBLE_FACTOR * 2, BUBBLE_FACTOR * 2);
    [[UIBezierPath bezierPathWithOvalInRect:drawingRect] fill];
    
    drawingRect.origin.y = self.bounds.size.height - (BUBBLE_FACTOR * 2);
    [[UIBezierPath bezierPathWithOvalInRect:drawingRect] fill];
    
    drawingRect.origin.y = 0;
    drawingRect.origin.x = self.bounds.size.width - (BUBBLE_FACTOR * 3);
    [[UIBezierPath bezierPathWithOvalInRect:drawingRect] fill];
    
    drawingRect = CGRectMake(BUBBLE_FACTOR, 0, self.bounds.size.width - (BUBBLE_FACTOR * 3), self.bounds.size.height);
    [[UIBezierPath bezierPathWithRect:drawingRect] fill];
    
    drawingRect = CGRectMake(0, BUBBLE_FACTOR, self.bounds.size.width - BUBBLE_FACTOR, self.bounds.size.height - (BUBBLE_FACTOR * 2));
    [[UIBezierPath bezierPathWithRect:drawingRect] fill];
    
    drawingRect = CGRectMake(self.bounds.size.width - (BUBBLE_FACTOR * 3), self.bounds.size.height - (BUBBLE_FACTOR * 2), BUBBLE_FACTOR * 2, BUBBLE_FACTOR * 2);
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    
    [arrowPath moveToPoint:CGPointMake(drawingRect.origin.x + (drawingRect.size.width / 2), drawingRect.origin.y + drawingRect.size.height)];
    
    CGPoint center = CGPointMake(drawingRect.origin.x + (drawingRect.size.width / 2), drawingRect.origin.y + (drawingRect.size.height / 2));
    [arrowPath addArcWithCenter:center radius:BUBBLE_FACTOR startAngle:DEGREES_TO_RADIANS(90) endAngle:DEGREES_TO_RADIANS(50) clockwise:NO];
    
    CGPoint endPoint = CGPointMake(self.bounds.size.width, self.bounds.size.height);
    [arrowPath addCurveToPoint:endPoint controlPoint1:arrowPath.currentPoint controlPoint2:CGPointMake(endPoint.x - BUBBLE_FACTOR, endPoint.y)];
    
    endPoint = CGPointMake(drawingRect.origin.x + drawingRect.size.width, drawingRect.origin.y + (drawingRect.size.height / 2));
    [arrowPath addCurveToPoint:endPoint controlPoint1:arrowPath.currentPoint controlPoint2:CGPointMake(endPoint.x, endPoint.y + (BUBBLE_FACTOR / 1.5))];
    
    endPoint = CGPointMake(drawingRect.origin.x + (drawingRect.size.width / 2), drawingRect.origin.y + (drawingRect.size.height / 2));
    [arrowPath addLineToPoint:endPoint];
    
    [arrowPath fill];
    
    UIGraphicsPopContext();
}


@end
