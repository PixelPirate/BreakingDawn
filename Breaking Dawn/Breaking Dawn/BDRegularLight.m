//
//  BDRegularLight.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 2/3/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDRegularLight.h"
#import "BDPlayer.h"

@interface BDRegularLight ()

@property (assign, readwrite, nonatomic) CFTimeInterval duration;

@property (assign, readwrite, nonatomic) CFTimeInterval reapear;

@property (assign, readwrite, nonatomic) CFAbsoluteTime appeared;

@property (assign, readwrite, nonatomic) CFAbsoluteTime disappeared;

@property (assign, readwrite, nonatomic) BOOL visible;

@end


@implementation BDRegularLight

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
    }
    return self;
}

- (void)evaluateForDelta:(NSTimeInterval)delta player:(BDPlayer *)player radius:(CGFloat)radius triggered:(void (^)(BDLight *))triggered
{
}

@end
