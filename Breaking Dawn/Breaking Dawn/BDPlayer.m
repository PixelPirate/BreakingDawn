//
//  BDPlayer.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/25/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDPlayer.h"

@interface BDPlayer ()

@property (assign, readwrite, nonatomic) CGPoint lastLocation;

@property (assign, readwrite, nonatomic) CGFloat lastLuminance;

@property (assign, readwrite, nonatomic) CGFloat luminanceDelta;

@end

@implementation BDPlayer

- (id)initWithPosition:(CGPoint)position
{
    self = [super init];
    if (self) {
        self.location = position;
        self.lastLocation = self.location;
        self.adrenalin = 0.0;
        self.lastLuminance = 1.0;
        self.luminanceDelta = 0.0;
    }
    return self;
}

- (void)setLocation:(CGPoint)location
{
    self.lastLocation = _location;
    _location = location;
    if (self.delegate) {
        [self.delegate playerDidMove:self toPosition:location];
    }
}

- (void)updateAdrenalin:(CGFloat)luminance
{
    self.luminanceDelta = self.lastLuminance - luminance;
    self.lastLuminance = luminance;
    
    CGFloat light = [[NSUserDefaults standardUserDefaults] floatForKey:@"AdrenalinLight"];
    CGFloat dusk = [[NSUserDefaults standardUserDefaults] floatForKey:@"AdrenalinDusk"];
    CGFloat dark = [[NSUserDefaults standardUserDefaults] floatForKey:@"AdrenalinDark"];
    
    if (luminance <= 1.0 && luminance >= 0.4) {
        self.adrenalin -= light;
    } else if (luminance < 0.4 && luminance > 0.1) {
        self.adrenalin += dusk;
    } else if (luminance < 0.1) {
        self.adrenalin += dark;
    }
    
    if (self.adrenalin > 1.0) {
        self.adrenalin = 1.0;
    } else if (self.adrenalin < 0.0) {
        self.adrenalin = 0.0;
    }
    
    if (self.adrenalinHandler) {
        self.adrenalinHandler();
    }
}

@end
