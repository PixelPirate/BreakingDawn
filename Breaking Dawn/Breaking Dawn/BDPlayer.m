//
//  BDPlayer.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/25/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDPlayer.h"

@implementation BDPlayer

- (id)initWithPosition:(CGPoint)position
{
    self = [super init];
    if (self) {
        self.location = position;
        self.adrenalin = 0.0;
    }
    return self;
}

- (void)setLocation:(CGPoint)location
{
    _location = location;
    if (self.delegate) {
        [self.delegate playerDidMove:self toPosition:location];
    }
}

@end
