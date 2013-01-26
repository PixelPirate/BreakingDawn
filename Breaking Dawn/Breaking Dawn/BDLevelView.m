//
//  BDLevelView.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/25/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDLevelView.h"
#import "BDLevel.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+UIImage_Extras.h"

@interface BDLevelView ()

@property (strong, readwrite, nonatomic) UIImageView *diffuseMapView;

@property (strong, readwrite, nonatomic) UIView *playerLayer;

@property (strong, readwrite, nonatomic) UIView *lightLayer;

@property (strong, readwrite, nonatomic) UIView *surfaceLayer;

@end


@implementation BDLevelView

- (id)initWithLevel:(BDLevel *)level
{
    CGFloat scale = [[NSUserDefaults standardUserDefaults] floatForKey:@"Scale"];
    
    self = [super initWithFrame:CGRectMake(0, 0, level.size.width*scale, level.size.height*scale)];
    if (self) {
        
        self.playerLayer = [[UIView alloc] initWithFrame:self.bounds];;
        self.surfaceLayer = [[UIView alloc] initWithFrame:self.bounds];;
        self.lightLayer = [[UIView alloc] initWithFrame:self.bounds];;
        
        [self addSubview:self.surfaceLayer];
        [self insertSubview:self.playerLayer aboveSubview:self.surfaceLayer];
        [self insertSubview:self.lightLayer aboveSubview:self.playerLayer];
        
        self.diffuseMapView = [[UIImageView alloc] initWithImage:level.diffuseMap];
        self.diffuseMapView.frame = self.bounds;
        [self.surfaceLayer addSubview:self.diffuseMapView];
        
        for (NSDictionary *pointRep in level.lights) {
            
            CGPoint p = CGPointZero;
            CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(pointRep), &p);
            
            UIView *light = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 224, 224)];
            light.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.4 alpha:0.8];
            
            UIImage *m = [UIImage maskView:light withMask:[UIImage imageNamed:@"light00-01.jpg"]];
            UIImageView *v = [[UIImageView alloc] initWithImage:m];
            v.center = p;
            
            [self.lightLayer addSubview:v];
            
            void(^__block flicker)(void) = ^(void) {
                [UIView animateWithDuration:0.1 animations:^{
                    v.alpha = 1.0 - arc4random_uniform(100)/800.0;
                }];
                int64_t delayInMilliseconds = (0.1+(arc4random_uniform(100)/1000.0))*1000.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInMilliseconds * NSEC_PER_MSEC);
                dispatch_after(popTime, dispatch_get_main_queue(), flicker);
            };
            
            dispatch_async(dispatch_get_main_queue(), flicker);
        }
    }
    return self;
}

@end
