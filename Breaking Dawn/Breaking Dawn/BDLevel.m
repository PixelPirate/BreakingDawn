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
#import "BDImageMap.h"
#import "BDHotspot.h"
#import "BDSound.h"

@interface BDLevel () // Private setter

@property (strong, readwrite, nonatomic) UIImage *diffuseMap;

@property (strong, readwrite, nonatomic) BDImageMap *lightMap;

@property (strong, readwrite, nonatomic) BDImageMap *collisionMap;

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
        UIImage *collision = [UIImage imageNamed:[name stringByAppendingString:@"_collision"]];
        self.collisionMap = [[BDImageMap alloc] initWithUIImage:collision];
        
        self.lights = [NSMutableArray array];
        NSURL *url = [[[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:@"map00.plist"] filePathURL];
        NSDictionary *mapInfos = [NSDictionary dictionaryWithContentsOfURL:url];
        for (NSDictionary *pointRep in mapInfos[@"Stages"][0][@"Lights"]) {
//            CGFloat scale = [[NSUserDefaults standardUserDefaults] floatForKey:@"Scale"];
//            NSNumber *x = [NSNumber numberWithFloat:[pointRep[@"X"] floatValue] * scale];
//            NSNumber *y = [NSNumber numberWithFloat:[pointRep[@"Y"] floatValue] * scale];
//            NSDictionary *p = [NSDictionary dictionaryWithObjectsAndKeys:@"X", x, @"Y", y, nil];
            
            [self.lights addObject:pointRep];
        }
        
        // Load lightmap from file or generate it if file is missing
        UIImage *light = [UIImage imageNamed:[name stringByAppendingString:@"_light"]];
        if (light) {
            self.lightMap = [[BDImageMap alloc] initWithUIImage:light];
        } else {
            [self loadLightmap];
        }
        
        self.lightScale = 1.0;
        
        self.mobs = [NSMutableArray array];
        [self.mobs addObject:[[BDMob alloc] initWithPosition:CGPointMake(300, 350)]];
        for (NSDictionary *pointRep in mapInfos[@"Stages"][0][@"Monsters"]) {
            CGPoint position = CGPointZero;
            CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(pointRep), &position);
            [self.mobs addObject:[[BDMob alloc] initWithPosition:position]];
        }
        
        CGSize imageSize = self.diffuseMap.size;
        
        CGPoint spawn = CGPointZero;
        CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(mapInfos[@"Stages"][0][@"Spawn"]), &spawn);
        self.spawn = spawn;
        
        self.size = imageSize;
        
        self.hotspots = [NSMutableArray array];
        [self.hotspots addObject:[[BDHotspot alloc] initWithFrame:CGRectMake(1196, 663, 80, 60) trigger:^{
            [[BDSound getInstance] playSound:SOUND_LIGHT_SWITCH];
            if (self.delegate) [self.delegate level:self willAddLights:mapInfos[@"Stages"][1][@"Lights"]];
            [self.lights addObjectsFromArray:mapInfos[@"Stages"][1][@"Lights"]];
        }]];
        
        
        [self.hotspots addObject:[[BDHotspot alloc] initWithFrame:CGRectMake(50, 705, 80, 100) trigger:^{
            if (self.delegate) [self.delegate levelWillWin:self];
        }]];
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

- (BOOL)isFreeX:(int)x andY:(int)y
{
    UIColor *color = [[self.collisionMap getRGBAsFromImageX:x andY:y count:1] lastObject];
    const CGFloat *components = CGColorGetComponents([color CGColor]);
    return (components[0] != 0);
}

- (BOOL)canMoveFrom:(CGPoint)from to:(CGPoint)to withLightLimit:(CGFloat)lightLimit
{
    // Check collision map for obsacles along the path from 'from' to 'to'
    // If a value in the light map is higher than 'lightLimit', it counts as an obstacle too!
    
    //NSLog(@"%@ %@ %@", NSStringFromSelector(_cmd), NSStringFromCGPoint(from), NSStringFromCGPoint(to));
    
    bool __block canMove = YES;
    [self line:from to:to usingBlock:^(int x, int y, BOOL *stop) {
        UIColor *color = [[self.collisionMap getRGBAsFromImageX:x andY:y count:1] lastObject];
        const CGFloat *components = CGColorGetComponents([color CGColor]);
        if(components[0] == 0) {
            canMove = NO;
            *stop = YES;
        }

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
    BDImageMap *lightmap = [[BDImageMap alloc] initWithUIImage:UIGraphicsGetImageFromCurrentImageContext()];
    UIGraphicsEndImageContext();
    
    self.lightMap = lightmap;
}

@end
