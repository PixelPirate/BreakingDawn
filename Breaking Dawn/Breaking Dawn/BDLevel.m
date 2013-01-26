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

@interface BDLevel () // Private setter

@property (strong, readwrite, nonatomic) UIImage *diffuseMap;

@property (strong, readwrite, nonatomic) UIImage *lightMap;

@property (strong, readwrite, nonatomic) UIImage *collisionMap;

@property (assign, readwrite, nonatomic) CGSize size;

@property (assign, readwrite, nonatomic) CGPoint spawn;

@property (strong, readwrite, nonatomic) NSMutableArray *lights;

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
        for (NSDictionary *pointRep in mapInfos[@"Lights"]) {
            [self.lights addObject:pointRep];
        }
        
        if (self.lightMap == nil) {
            [self loadLightmap];
        }
        
        CGSize imageSize = self.diffuseMap.size;
        
        self.spawn = CGPointMake(imageSize.width/2.0, imageSize.height/2.0);
        
        self.size = imageSize;
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

- (void)line:(CGPoint)from to:(CGPoint)to usingBlock:(void (^)(int x, int y))block
{
    float x0=from.x, y0=from.y;
    float x1=to.x, y1=to.y;
    
    // Check if x difference is bigger than y differene, than swap now and later call block swapped
    bool steep = (abs(y1-y0) > abs(x1-x0));
    if(steep) {
        float swap;
        swap=y0; x0=y0; y0=swap;
        swap=y1; x1=y1; y1=swap;
    }
    
    // Run from left to right or from right to left
    int inc = x1 > x0 ? 1 : -1;
    
    for(int x=x0; (inc>0) ? (x<=x1) : (x>=x1); x+=inc) {
        float progress = (x-x0)/(x1-x0);
        int y = y0 + (y1-y0)*progress;
        if(steep) block(x, y); else block(y, x);
    }
}

- (BOOL)canMoveFrom:(CGPoint)from to:(CGPoint)to withLightLimit:(CGFloat)lightLimit
{
    // Check collision map for obsacles along the path from 'from' to 'to'
    // If a value in the light map is higher than 'lightLimit', it counts as an obstacle too!
    
    [self line:from to:to usingBlock:^(int x, int y) {
//        NSLog(@"%d %d", x, y);
    }];
    
    return YES;
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
