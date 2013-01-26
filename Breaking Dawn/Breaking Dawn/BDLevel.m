//
//  BDLevel.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/25/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDLevel.h"
#import "UIImage+UIImage_Extras.h"
#import <QuartzCore/QuartzCore.h>
#import "BDMob.h"
#import "BDHotspot.h"

@interface BDLevel () // Private setter

@property (strong, readwrite, nonatomic) UIImage *diffuseMap;

@property (strong, readwrite, nonatomic) UIImage *lightMap;

@property (strong, readwrite, nonatomic) UIImage *collisionMap;

@property (assign, readwrite, nonatomic) CGSize size;

@property (assign, readwrite, nonatomic) CGPoint spawn;

@property (strong, readwrite, nonatomic) NSMutableArray *lights;

@property (strong, readwrite, nonatomic) NSMutableArray *mobs;

@property (strong, readwrite, nonatomic) NSDictionary *stages;

- (void)loadLightmap;

@end


@implementation BDLevel

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        self.diffuseMap = [UIImage imageNamed:[name stringByAppendingString:@"_diffuse"]];
        self.lightMap = [UIImage imageNamed:[name stringByAppendingString:@"_light"]];
        self.collisionMap = [UIImage imageNamed:[name stringByAppendingString:@"_collision"]];
        
        self.lights = [NSMutableArray array];
        NSURL *url = [[[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:@"map00.plist"] filePathURL];
        NSDictionary *mapInfos = [NSDictionary dictionaryWithContentsOfURL:url];
        for (NSDictionary *pointRep in mapInfos[@"Stages"][0][@"Lights"]) {
            [self.lights addObject:pointRep];
        }
        
        if (self.lightMap == nil) {
            [self loadLightmap];
        }
        
        self.lightScale = 1.0;
        
        self.mobs = [NSMutableArray array];
        [self.mobs addObject:[[BDMob alloc] initWithPosition:CGPointMake(300, 350)]];
        
        CGSize imageSize = self.diffuseMap.size;
        
        self.spawn = CGPointMake(imageSize.width/2.0, imageSize.height/2.0);
        
        self.size = imageSize;
        
        self.hotspots = [NSMutableArray array];
        [self.hotspots addObject:[[BDHotspot alloc] initWithFrame:CGRectMake(1111, 700, 130, 100) trigger:^{
//            [self.lights addObjectsFromArray:mapInfos[@"Stages"][0][@"Lights"]];
            //if (self.delegate) [self.delegate levelChangedData:self];
            if (self.delegate) [self.delegate level:self willAddLights:mapInfos[@"Stages"][1][@"Lights"]];
        }]];
        
        // Precache images
        if (self.collisionMap == nil) {
            self.collisionMap = self.diffuseMap;
        }
        [UIImage getRGBAsFromImage:self.collisionMap atX:0 andY:0 count:1];
        [UIImage getRGBAsFromImage:self.lightMap atX:0 andY:0 count:1];
    }
    return self;
}

+ (BDLevel *)levelNamed:(NSString *)name
{
    BDLevel *level = [[BDLevel alloc] initWithName:name];
    return level;
}

- (BOOL)canMoveFrom:(CGPoint)from to:(CGPoint)to
{
    return [self canMoveFrom:from to:to withLightLimit:CGFLOAT_MAX];
}

- (void)line:(CGPoint)from to:(CGPoint)to usingBlock:(void (^)(int x, int y, BOOL *stop))block
{
    float x0=from.x, y0=from.y;
    float x1=to.x, y1=to.y;
    
    // Check if x difference is bigger than y differene, than swap now and later call block swapped
    bool steep = (abs(y1-y0) > abs(x1-x0));
    if(steep) {
        float swap;
        swap=x0; x0=y0; y0=swap;
        swap=x1; x1=y1; y1=swap;
    }
    
    // Run from left to right or from right to left
    int inc = x1 > x0 ? 1 : -1;
    
    for(int x=x0; (inc>0) ? (x<=(int)x1) : (x>=(int)x1); x+=inc) {
        float progress = (x-x0)/(x1-x0);
        int y = y0 + (y1-y0)*progress;
        BOOL stop = NO;
        if(steep) block(y, x, &stop); else block(x, y, &stop);
        if (stop) {
            break;
        }
    }
}

- (BOOL)canMoveFrom:(CGPoint)from to:(CGPoint)to withLightLimit:(CGFloat)lightLimit
{
    // Check collision map for obsacles along the path from 'from' to 'to'
    // If a value in the light map is higher than 'lightLimit', it counts as an obstacle too!
    
    //NSLog(@"%@ %@ %@", NSStringFromSelector(_cmd), NSStringFromCGPoint(from), NSStringFromCGPoint(to));
    
    bool __block canMove = YES;
    [self line:from to:to usingBlock:^(int x, int y, BOOL *stop) {
        UIColor *color = [[UIImage getRGBAsFromImage:self.collisionMap atX:x andY:y count:1] lastObject];
        const CGFloat *components = CGColorGetComponents([color CGColor]);
        if(components[0] == 0) {
            canMove = NO;
            *stop = YES;
        }
        
//        if (/*lightLimit != CGFLOAT_MAX &&*/ canMove) {
//            color = [[UIImage getRGBAsFromImage:self.lightMap atX:x andY:y count:1] lastObject];
//            CGFloat alpha = 0.0;
//            CGFloat r = 0.0;
//            CGFloat g = 0.0;
//            CGFloat b = 0.0;
//            [color getRed:&r green:&g blue:&b alpha:&alpha];
//            //components = CGColorGetComponents([color CGColor]);
//            printf("%f %f %f %f\n", 1.0-r, 1.0-g, 1.0-b, 1.0-alpha);
//            if (alpha > lightLimit) {
//                canMove = NO;
//                *stop = YES;
//            }
//        }
    }];
    
    if (canMove && lightLimit != CGFLOAT_MAX) {
        [self line:from to:to usingBlock:^(int x, int y, BOOL *stop) {
            for (NSDictionary *light in self.lights) {
                CGPoint lightPosition = CGPointZero;
                CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(light), &lightPosition);
                CGFloat fakeRadius = 80.0 * self.lightScale;
                
                BOOL(^PointInsideCircle)(CGPoint p, CGPoint center, CGFloat radius) = ^(CGPoint p, CGPoint center, CGFloat radius) {
                    if ((pow(p.x-center.x, 2.0) + pow(p.y - center.y, 2.0)) < pow(radius, 2.0)) {
                        return YES;
                    } else {
                        return NO;
                    }
                };
                
                if (PointInsideCircle(CGPointMake(x, y), lightPosition, fakeRadius)) {
                    canMove = NO;
                    *stop = YES;
                }
            }
        }];
    }
    
    
    return canMove;
}

- (void)loadLightmap
{
    UIGraphicsBeginImageContext(self.diffuseMap.size);
    [[UIColor blackColor] set];
    UIRectFill(CGRectMake(0, 0, self.diffuseMap.size.width, self.diffuseMap.size.height));
    
    for (NSDictionary *pointRep in self.lights) {
        CGPoint p = CGPointZero;
        CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(pointRep), &p);
        
        UIView *light = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 224, 224)];
        light.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.4 alpha:0.8];
        
        UIImage *m = [UIImage maskView:light withMask:[UIImage imageNamed:@"light00-01.jpg"]];
        UIImageView *v = [[UIImageView alloc] initWithImage:m];
        v.center = p;
        
        CGContextSaveGState(UIGraphicsGetCurrentContext());
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), v.frame.origin.x, v.frame.origin.y);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeDestinationOut);
        [v.layer renderInContext:UIGraphicsGetCurrentContext()];
        CGContextRestoreGState(UIGraphicsGetCurrentContext());
    }
    UIImage *lightmap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.lightMap = lightmap;
}

@end
