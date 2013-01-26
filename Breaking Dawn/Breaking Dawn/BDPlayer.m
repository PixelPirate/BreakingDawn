//
//  BDPlayer.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/25/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDPlayer.h"

@interface BDPlayer ()

@property (assign, readwrite, nonatomic) CGFloat lastLuminance;

@property (assign, readwrite, nonatomic) CGFloat luminanceDelta;

@end

@implementation BDPlayer

- (id)initWithPosition:(CGPoint)position
{
    self = [super init];
    if (self) {
        self.location = position;
        self.adrenalin = 0.0;
        self.lastLuminance = 1.0;
        self.luminanceDelta = 0.0;
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

- (void)updateAdrenalin:(CGFloat)luminance
{
    self.luminanceDelta = self.lastLuminance - luminance;
    self.lastLuminance = luminance;
    
    if (luminance < 0.3) {
        self.adrenalin += (1.0 - luminance) * 0.006;
        if (self.adrenalin > 1.0) {
            self.adrenalin = 1.0;
        }
    } else {
        self.adrenalin -= (1.0 - luminance) * 0.05;
        if (self.adrenalin < 0.0) {
            self.adrenalin = 0.0;
        }
    }
    
    if (self.adrenalinHandler) {
        self.adrenalinHandler();
    }
}

@end
