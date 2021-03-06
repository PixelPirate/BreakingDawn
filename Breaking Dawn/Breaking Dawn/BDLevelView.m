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

@property (weak, readwrite, nonatomic) BDLevel *level;

@property (strong, readwrite, nonatomic) UIImageView *lightSwitch;

@property (strong, readwrite, nonatomic) UIImageView *exitImage;

@property (strong, readwrite, nonatomic) NSMutableArray *displayedLights;

@property (assign, readwrite, nonatomic) CGFloat lightScale;

@property (strong, readwrite, nonatomic) NSTimer *flickerTimer;

@property (strong, readwrite, nonatomic) NSMutableArray *flickeringLightsTimers;

@property (strong, readwrite, nonatomic) NSMutableArray *decalViews;

@property (strong, readwrite, nonatomic) NSMutableArray *mobViews;

@property (strong, readwrite, nonatomic) NSMutableArray *displayedMobs;

- (void)beginPulsating;

- (void)endPulsating;

- (void)pulsate;

- (void)flicker:(NSTimer *)timer;

@end


@implementation BDLevelView

- (id)initWithLevel:(BDLevel *)level
{
    CGFloat scale = [[NSUserDefaults standardUserDefaults] floatForKey:@"Scale"];
    
    self = [super initWithFrame:CGRectMake(0, 0, level.size.width*scale, level.size.height*scale)];
    if (self) {
        
        self.level = level;
        self.dataSource = level;
        
        self.playerLayer = [[UIView alloc] initWithFrame:self.bounds];;
        self.surfaceLayer = [[UIView alloc] initWithFrame:self.bounds];;
        self.lightLayer = [[UIView alloc] initWithFrame:self.bounds];;
        self.pulse = 0.0;
        self.displayedLights = [NSMutableArray array];
        self.flickeringLightsTimers = [NSMutableArray array];
        
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.surfaceLayer];
        [self insertSubview:self.playerLayer aboveSubview:self.surfaceLayer];
        [self insertSubview:self.lightLayer aboveSubview:self.playerLayer];
        
        self.diffuseMapView = [[UIImageView alloc] initWithImage:level.diffuseMap];
        self.diffuseMapView.frame = self.bounds;
        [self.surfaceLayer addSubview:self.diffuseMapView];
        
        self.pulsatingViews = [NSMutableArray array];
        self.decalViews = [NSMutableArray array];
        self.mobViews = [NSMutableArray array];
        self.displayedMobs = [NSMutableArray array];
        
        [self reloadData];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"Warning, never called! Each BDLevelView leaks!");
    [self.flickeringLightsTimers makeObjectsPerformSelector:@selector(invalidate)];
    [self.mobViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.mobViews removeAllObjects];
    [self.displayedMobs removeAllObjects];
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

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview == nil) {
        [self endPulsating];
    }
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
    if (![self.displayedLights isEqualToArray:[self.dataSource lightsInLevelView:self]]) {
        
        //TODO: Instead of removing everything, make a list of new and lost objects.
        [self.lightLayer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.displayedLights removeAllObjects];
        [self.flickeringLightsTimers makeObjectsPerformSelector:@selector(invalidate)];
        [self.flickeringLightsTimers removeAllObjects];
        
        CGFloat scale = [[NSUserDefaults standardUserDefaults] floatForKey:@"Scale"];
        for (NSValue *light in [self.dataSource lightsInLevelView:self]) {
            CGPoint p = [light CGPointValue];
            p = CGPointApplyAffineTransform(p, CGAffineTransformMakeScale(scale, scale));
            
            UIView *light = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 224, 224)];
            light.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.4 alpha:0.8];
            
            UIImage *m = [UIImage maskView:light withMask:[UIImage imageNamed:@"light00-01.jpg"]];
            self.normalLight = m;
            light.backgroundColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.4 alpha:0.8];
            self.evilLight = [UIImage maskView:light withMask:[UIImage imageNamed:@"light00-01.jpg"]];
            
            UIImageView *v = [[UIImageView alloc] initWithImage:self.normalLight];
            v.contentMode = UIViewContentModeScaleAspectFit;
            v.center = p;
            
            [self.lightLayer addSubview:v];
            [self.displayedLights addObject:[NSValue valueWithCGPoint:p]];
            
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:(0.1+(arc4random_uniform(100)/1000.0))
                                                              target:self
                                                            selector:@selector(flicker:)
                                                            userInfo:v
                                                             repeats:NO];
            [self.flickeringLightsTimers addObject:timer];
        }
        [self.pulsatingViews removeAllObjects];
        for (UIImageView *i in self.lightLayer.subviews) {
            if ([i isKindOfClass:[UIImageView class]]) {
                UIImageView *pulse = [[UIImageView alloc] initWithImage:self.evilLight];
                pulse.frame = i.frame;
                pulse.alpha = 0.0;
                [self.lightLayer addSubview:pulse];
                [self.pulsatingViews addObject:pulse];
            }
        }
    }
    
    CGFloat scale = [[NSUserDefaults standardUserDefaults] floatForKey:@"Scale"];
    CGSize lightSize = CGSizeMake(224*scale, 224*scale);
    self.lightScale = [self.dataSource lightScaleInLevelView:self];
    for (UIImageView *i in self.lightLayer.subviews) {
        if ([i isKindOfClass:[UIImageView class]] /*&& ![self.pulsatingViews containsObject:i]*/) {
            CGSize size = CGSizeApplyAffineTransform(lightSize, CGAffineTransformMakeScale(self.lightScale, self.lightScale));
            CGPoint center = i.center;
            i.frame = CGRectMake(0, 0, size.width, size.height);
            i.center = center;
        }
    }
    
    
    //TODO: Instead of removing everything, make a list of new and lost objects.
    [self.decalViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.decalViews removeAllObjects];
    for (NSDictionary *decal in self.level.decals) {
        UIImageView *decalView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:decal[@"imageName"]]];
        decalView.frame = CGRectMake([decal[@"Origin"] CGPointValue].x * scale,
                                     [decal[@"Origin"] CGPointValue].y * scale,
                                     decalView.image.size.width * scale,
                                     decalView.image.size.height * scale);
        [self.decalViews addObject:decalView];
    }
    for (UIView *view in self.decalViews) {
        [self addSubview:view];
    }
    
    if (![self.displayedMobs isEqualToArray:self.level.mobs]) {
        [self.mobViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.mobViews removeAllObjects];
        [self.displayedMobs removeAllObjects];
        for (BDMob *mob in self.level.mobs) {
            BDMobView *mobView = [[BDMobView alloc] initWithMob:mob];
            mobView.hidden = YES;
            [self.playerLayer addSubview:mobView];
            [self.mobViews addObject:mobView];
            [self.displayedMobs addObject:mob];
        }
    }
}

- (void)flicker:(NSTimer *)timer
{
    id obj = timer.userInfo;
    if ([obj isKindOfClass:[UIView class]]) {
        UIView *view = obj;
        view.alpha = 1.0 - arc4random_uniform(100)/800.0;
        [NSTimer scheduledTimerWithTimeInterval:(0.1+(arc4random_uniform(100)/1000.0))
                                         target:self
                                       selector:@selector(flicker:)
                                       userInfo:view
                                        repeats:NO];
    }
}

@end
