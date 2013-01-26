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
#import "BDMob.h"
#import "BDMobView.h"

@interface BDLevelView ()

@property (strong, readwrite, nonatomic) UIImageView *diffuseMapView;

@property (strong, readwrite, nonatomic) UIView *playerLayer;

@property (strong, readwrite, nonatomic) UIView *lightLayer;

@property (strong, readwrite, nonatomic) UIView *surfaceLayer;

@property (strong, readwrite, nonatomic) UIImage *normalLight;

@property (strong, readwrite, nonatomic) UIImage *evilLight;

@property (strong, readwrite, nonatomic) NSMutableArray *pulsatingViews;

@property (strong, readwrite, nonatomic) NSTimer *pulseTimer;

@property (strong, readwrite, nonatomic) BDLevel *level;

- (void)beginPulsating;

- (void)endPulsating;

- (void)pulsate;

@end


@implementation BDLevelView

- (id)initWithLevel:(BDLevel *)level
{
    CGFloat scale = [[NSUserDefaults standardUserDefaults] floatForKey:@"Scale"];
    
    self = [super initWithFrame:CGRectMake(0, 0, level.size.width*scale, level.size.height*scale)];
    if (self) {
        
        self.level = level;
        self.playerLayer = [[UIView alloc] initWithFrame:self.bounds];;
        self.surfaceLayer = [[UIView alloc] initWithFrame:self.bounds];;
        self.lightLayer = [[UIView alloc] initWithFrame:self.bounds];;
        self.pulse = 0.0;
        
        self.backgroundColor = [UIColor blackColor];
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
            self.normalLight = m;
            light.backgroundColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.4 alpha:0.8];
            self.evilLight = [UIImage maskView:light withMask:[UIImage imageNamed:@"light00-01.jpg"]];
            
            UIImageView *v = [[UIImageView alloc] initWithImage:self.normalLight];
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
        
        self.pulsatingViews = [NSMutableArray array];
        for (UIImageView *i in self.lightLayer.subviews) {
            if ([i isKindOfClass:[UIImageView class]]) {
                UIImageView *pulse = [[UIImageView alloc] initWithImage:self.evilLight];
                pulse.frame = i.frame;
                pulse.alpha = 0.0;
                [self.lightLayer addSubview:pulse];
                [self.pulsatingViews addObject:pulse];
            }
        }
        
        for (BDMob *mob in level.mobs) {
            BDMobView *mobView = [[BDMobView alloc] initWithMob:mob];
            [self.surfaceLayer addSubview:mobView];
        }
    }
    return self;
}

- (void)beginPulsating
{
    if (self.pulseTimer.isValid) {
        return;
    }
    self.pulseTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(pulsate) userInfo:nil repeats:YES];
}

- (void)endPulsating
{
    [self.pulseTimer invalidate];
}

- (void)pulsate
{
    for (UIImageView *pulse in self.pulsatingViews) {
        CGRect originalFrame = pulse.frame;
        CGFloat extent = 50.0;
        CGRect zoomed = CGRectMake(pulse.frame.origin.x - extent/2.0,
                                   pulse.frame.origin.y - extent/2.0,
                                   pulse.frame.size.width + extent,
                                   pulse.frame.size.height + extent);
        
        [UIView animateWithDuration:0.5 animations:^{
            pulse.alpha = 1.0;
            pulse.frame = zoomed;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                pulse.alpha = 0.0;
                pulse.frame = originalFrame;
            }];
        }];
    }
}

- (void)setLightScale:(CGFloat)scale
{
    CGSize lightSize = CGSizeMake(224, 224);
    _lightScale = scale;
    self.level.lightScale = scale;
    for (UIImageView *i in self.lightLayer.subviews) {
        if ([i isKindOfClass:[UIImageView class]] /*&& ![self.pulsatingViews containsObject:i]*/) {
            CGSize size = CGSizeApplyAffineTransform(lightSize, CGAffineTransformMakeScale(scale, scale));
            CGPoint center = i.center;
            i.frame = CGRectMake(0, 0, size.width, size.height);
            i.center = center;
        }
    }
}

- (void)setPulse:(CGFloat)pulse
{
    _pulse = pulse;
    if (pulse > 0.1) {
        [self beginPulsating];
    } else {
        [self endPulsating];
    }
}

- (void)reloadData
{
    
}

@end
