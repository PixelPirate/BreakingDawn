//
//  BDTrapLight.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 2/3/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDTrapLight.h"
#import "BDPlayer.h"

@interface BDTrapLight ()

@property (assign, readwrite, nonatomic) CFTimeInterval duration;

@property (assign, readwrite, nonatomic) CFTimeInterval reapear;

@property (assign, readwrite, nonatomic) CFAbsoluteTime appeared;

@property (assign, readwrite, nonatomic) CFAbsoluteTime disappeared;

@property (assign, readwrite, nonatomic) BOOL visible;

@property (assign, readwrite, nonatomic) BOOL triggered;

@property (assign, readwrite, nonatomic) BOOL canReappear;

@end


@implementation BDTrapLight

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
        self.location = location;
        self.triggered = NO;
        self.canReappear = (reappear > 0.0);
        self.visible = YES;
    }
    return self;
}

static inline BOOL CircleContainsPoint(CGPoint center, CGFloat radius, CGPoint p)
{
    if ((pow(p.x-center.x, 2.0) + pow(p.y - center.y, 2.0)) < pow(radius, 2.0)) {
        return YES;
    } else {
        return NO;
    }
}

- (void)evaluateForDelta:(NSTimeInterval)delta player:(BDPlayer *)player radius:(CGFloat)radius triggered:(void (^)(BDLight *))triggered
{
    if (!self.canReappear && self.triggered) return; // Light is off and can not be turned on again.
    
    if (CircleContainsPoint(self.location, radius, player.location) && !self.triggered) {
        // Player entered light, light will go off in 'duration' seconds.
        self.triggered = YES;
        int64_t delayInMilliseconds = self.duration * 1000.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInMilliseconds * NSEC_PER_MSEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.visible = NO;
            triggered(self);
        });
        
        if (self.canReappear) {
            int64_t delayInMilliseconds = (self.duration + self.reapear) * 1000.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInMilliseconds * NSEC_PER_MSEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.triggered = NO; // Ready to be triggered again.
                self.visible = YES;
                triggered(self);
            });
        }
    }
}

@end
