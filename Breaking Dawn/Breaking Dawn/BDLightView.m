//
//  BDLightView.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/30/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDLightView.h"
#import "BDLevel.h"

@interface BDLightView ()

@property (assign, readwrite, nonatomic) CGFloat radius;

@property (weak, readwrite, nonatomic) BDImageMap *collisionMap;

@property (weak, readwrite, nonatomic) BDLevel *level;

@end


@implementation BDLightView

- (id)initWithPosition:(CGPoint)position inLevel:(BDLevel *)level
{
    self = [super initWithFrame:CGRectMake(position.x, position.y, 0, 0)];
    if (self) {
        self.level = level;
        self.radius = [[NSUserDefaults standardUserDefaults] floatForKey:@"DefaultLightRadius"];
        self.radius = 280;
        self.frame = CGRectInset(self.frame, -self.radius, -self.radius);
        self.collisionMap = level.collisionMap;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

static inline BOOL CircleContainsCGPoint(const CGPoint *center, const CGFloat *radius, const CGPoint *p)
{
    return pow((p->x-center->x), 2) + pow((p->y - center->y), 2) < pow(*radius, 2);
}

- (void)drawRect:(CGRect)rect
{
    // Drawing realistic light using the collision map from level
    CGPoint center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
    
    NSArray *corners = self.level.corners;
    corners = [corners filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        CGPoint p = [evaluatedObject CGPointValue];
        return CircleContainsCGPoint(&center, &_radius, &p);
    }]];
    NSLog(@"%@", corners);
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    UIColor *innerGradientColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.2 alpha:0.4];
    UIColor *outerGradientColor = [UIColor clearColor];
    
    CGFloat locations[2] = {0.0 ,1.0};
    CFArrayRef colors = (__bridge CFArrayRef)([NSArray arrayWithObjects:(id)innerGradientColor.CGColor,
                                               (id)outerGradientColor.CGColor,
                                               nil]);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, locations);
    
    CGContextDrawRadialGradient(context,
                                gradient,
                                center,
                                self.radius / 2.0,
                                center,
                                self.radius,
                                kCGGradientDrawsBeforeStartLocation);
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}

- (void)setRadius:(CGFloat)radius animated:(BOOL)animated
{
    
}

- (CGFloat)illuminationOfPoint:(CGPoint)point
{
    return 0.0;
}

@end
