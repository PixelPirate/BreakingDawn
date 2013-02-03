//
//  BDTimedLight.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 2/3/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDTimedLight.h"
#import "BDPlayer.h"
#import "BDSound.h"


@interface BDTimedLight ()

@property (assign, readwrite, nonatomic) CFTimeInterval duration;

@property (assign, readwrite, nonatomic) CFTimeInterval reapear;

@property (assign, readwrite, nonatomic) CFAbsoluteTime appeared;

@property (assign, readwrite, nonatomic) CFAbsoluteTime disappeared;

@property (assign, readwrite, nonatomic) BOOL visible;

@property (assign, readwrite, nonatomic) BOOL appearing;

@property (assign, readwrite, nonatomic) BOOL canReappear;

@end


@implementation BDTimedLight

- (id)initWithDuration:(NSTimeInterval)duration
      reappearIntetval:(NSTimeInterval)reappear
       playerTriggered:(BOOL)player
              location:(CGPoint)location
{
    self = [super init];
    if (self) {
        self.duration = duration;
        self.reapear = reappear;
        self.appeared = 0.0;
        self.disappeared = 0.0;
        self.canReappear = (reappear > 0.0);
        self.location = location;
        self.visible = YES;
    }
    return self;
}

- (void)evaluateForDelta:(NSTimeInterval)delta player:(BDPlayer *)player radius:(CGFloat)radius triggered:(void (^)(BDLight *))triggered
{
    if (!self.canReappear && self.appearing) return; // Light is off and can not be turned on again.
    
    
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();    
    
    if (!self.appearing) { // Light is on, check if it's time to go off.
        NSTimeInterval duration = currentTime - self.appeared; // How many seconds passed since the light was activated.
        if (duration > self.duration) { // If the light was on long enough, turn off.
            self.visible = NO;
            
            triggered(self);
            
            self.appearing = YES; // Light is off and might reappear.
            self.disappeared = currentTime;
        }
    } else if (self.canReappear) { // Light is off, check if it's time to go on.
        NSTimeInterval duration = currentTime - self.disappeared; // How many seconds passed since the light was deactivated.
        if (duration > self.reapear) { // If the light was off long enought, turn on.
            self.visible = YES;
            
            triggered(self);
            
            self.appearing = NO; // Light is on and might dissappear.
            self.appeared = currentTime;
        }
    }
}


@end
