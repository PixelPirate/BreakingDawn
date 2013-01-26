//
//  BDMob.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDMob.h"

@implementation BDMob

- (id)initWithPosition:(CGPoint)position
{
    self = [super init];
    if (self) {
        self.location = position;
    }
    return self;
}

- (void)setLocation:(CGPoint)location
{
    _location = location;
    if (self.delegate) {
        [self.delegate mobDidMove:self toPosition:location];
    }
}

@end
