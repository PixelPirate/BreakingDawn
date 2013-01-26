//
//  BDHotspot.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDHotspot.h"

typedef void (^BDTrigger)(void);

@interface BDHotspot ()

@property (copy, readwrite, nonatomic) BDTrigger trigger;

@property (assign, readwrite, nonatomic) BOOL active;

@end


@implementation BDHotspot

- (id)initWithFrame:(CGRect)frame trigger:(void (^)())trigger
{
    self = [super init];
    if (self) {
        self.frame = frame;
        self.trigger = trigger;
        self.toggle = NO;
        self.active = YES;
    }
    return self;
}

- (void)test:(CGPoint)position
{
    if (self.active) {
        if (CGRectContainsPoint(self.frame, position)) {
            self.trigger();
            if (!self.toggle) {
                self.active = NO;
            }
        }
    }
}

@end
