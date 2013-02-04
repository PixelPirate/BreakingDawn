//
//  BDLight.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 2/3/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDLight.h"
#import "BDTimedLight.h"
#import "BDTrapLight.h"
#import "BDRegularLight.h"

@implementation BDLight

+ (BDLight *)light
{
    BDLight *regularLight = [[BDRegularLight alloc] initWithDuration:0.0
                                                    reappearIntetval:0.0
                                                     playerTriggered:NO
                                                            location:CGPointZero];
    return regularLight;
}

+ (BDLight *)timedLight
{
    BDLight *timedLight = [[BDTimedLight alloc] initWithDuration:5.0
                                                reappearIntetval:5.0
                                                 playerTriggered:NO
                                                        location:CGPointZero];
    return timedLight;
}

+ (BDLight *)trapLight
{
    BDLight *trapLight = [[BDTrapLight alloc] initWithDuration:5.0
                                              reappearIntetval:5.0
                                               playerTriggered:YES
                                                      location:CGPointZero];
    return trapLight;
}

+ (BDLight *)lightWithDuration:(NSTimeInterval)duration
              reappearIntetval:(NSTimeInterval)reappear
               playerTriggered:(BOOL)playerTriggered
                      location:(CGPoint)location
{
    BDLight *light = [[BDLight alloc] initWithDuration:duration
                                      reappearIntetval:reappear
                                       playerTriggered:playerTriggered
                                              location:location];
    return light;
}

- (id)initWithDuration:(NSTimeInterval)duration
      reappearIntetval:(NSTimeInterval)reappear
       playerTriggered:(BOOL)playerTriggered
              location:(CGPoint)location
{
    
    if ((duration == DBL_MAX || duration <= 0.0) && (reappear == DBL_MAX || reappear <= 0.0)) {
        BDLight *light = [[BDRegularLight alloc] initWithDuration:0.0
                                                 reappearIntetval:0.0
                                                  playerTriggered:NO
                                                         location:location];
        self = light;
    } else if (playerTriggered) {
        BDLight *light = [[BDTrapLight alloc] initWithDuration:duration
                                              reappearIntetval:reappear
                                               playerTriggered:YES
                                                      location:location];
        self = light;
    } else {
        BDLight *light = [[BDTimedLight alloc] initWithDuration:duration
                                               reappearIntetval:reappear
                                                playerTriggered:NO
                                                       location:location];
        self = light;
    }
    
    if (self == nil) {
        [NSException raise:NSInvalidArgumentException format:@"Could not consruct fitting BDLight with given arguments: {duration:%f, reapear:%f, playerTriggered:%@}", duration, reappear, (playerTriggered ? @"YES" : @"NO")];
    }
    
    return self;
}

- (void)evaluateForDelta:(NSTimeInterval)delta
                  player:(BDPlayer *)player
                  radius:(CGFloat)radius
               triggered:(void (^)(BDLight *))triggered
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)setLocation:(CGPoint)location
{
    [self doesNotRecognizeSelector:_cmd];
}

- (CGPoint)location
{
    [self doesNotRecognizeSelector:_cmd];
    return CGPointZero;
}

- (BOOL)visible
{
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (void)setAppeared:(CFAbsoluteTime)appeared
{
    [self doesNotRecognizeSelector:_cmd];
}

@end
