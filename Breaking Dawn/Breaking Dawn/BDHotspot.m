//
//  BDHotspot.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDHotspot.h"
#import "BDLevel.h"
#import "BDSound.h"

typedef void (^BDTrigger)(void);

@interface BDHotspot ()

@property (copy, readwrite, nonatomic) BDTrigger trigger;

@property (assign, readwrite, nonatomic) BOOL active;

@property (strong, readwrite, nonatomic) NSArray *changes;

@property (assign, readwrite, nonatomic) NSUInteger changeIndex;

@property (assign, readwrite, nonatomic) NSInteger state;

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
        self.state = 0;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.frame = frame;
        self.toggle = NO;
        self.active = YES;
        self.changeIndex = 0;
        self.state = 0;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame changes:(NSArray *)changes level:(BDLevel *)level
{
    self = [self initWithFrame:frame];
    if (self) {
        self.trigger = ^{
            NSDictionary *change = changes[self.changeIndex % changes.count];
            self.changeIndex ++;
            NSArray *removedLights = change[@"RemoveLights"];
            NSArray *addedLights = change[@"AddLights"];
            NSArray *addedTimeLights = change[@"AddTimeLights"];
            NSArray *addedTrapLights = change[@"AddTrapLights"];
            
            for (NSArray *positionRep in removedLights) {
                NSValue *position = [NSValue valueWithCGPoint:CGPointMake([positionRep[0] floatValue], [positionRep[1] floatValue])];
                [level.lights removeObject:position];
            }
            
            for (NSArray *positionRep in addedLights) {
                NSValue *position = [NSValue valueWithCGPoint:CGPointMake([positionRep[0] floatValue], [positionRep[1] floatValue])];
                [level.lights addObject:position];
            }
            
            for (NSArray *positionRep in addedTimeLights) {
                NSValue *position = [NSValue valueWithCGPoint:CGPointMake([positionRep[0] floatValue], [positionRep[1] floatValue])];
            }
            
            for (NSArray *positionRep in addedTrapLights) {
                NSValue *position = [NSValue valueWithCGPoint:CGPointMake([positionRep[0] floatValue], [positionRep[1] floatValue])];
            }
            
            switch (self.state) {
                case 0: // Inactive decal
                    [level exchangeDecal:self.activeDecal withDecal:self.inactiveDecal];
                    [[BDSound sharedSound] playSoundNamed:self.inactiveDecal[@"Sound"]];
                    break;
                case 1: // Active decal
                    [level exchangeDecal:self.inactiveDecal withDecal:self.activeDecal];
                    [[BDSound sharedSound] playSoundNamed:self.activeDecal[@"Sound"]];
                    break;
                default:
                    break;
            }
            
            [level.delegate level:level didAddLights:addedLights]; // Badly named, asks the view to reload data in current implementation.
        };
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame stageChange:(NSString *)stage level:(BDLevel *)level
{
    self = [self initWithFrame:frame];
    if (self) {
        self.trigger = ^{
            switch (self.state) {
                case 0: // Inactive decal
                    [level exchangeDecal:self.activeDecal withDecal:self.inactiveDecal];
                    break;
                case 1: // Active decal
                    [level exchangeDecal:self.inactiveDecal withDecal:self.activeDecal];
                    break;
                default:
                    break;
            }
        };
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame levelChange:(NSString *)levelName level:(BDLevel *)level
{
    self = [self initWithFrame:frame];
    if (self) {
        self.trigger = ^{
            if ([levelName isEqualToString:@"Credits"]) {
                [level.delegate levelWillWin:level];
            } else if ([levelName isEqualToString:@"GameOver"]) {
                //[level.delegate levelWillLoose:level];
            } else {
                //[level.delegate level:level loadLevel:levelName];
            }
        };
    }
    return self;
}

- (void)test:(CGPoint)position
{
    if (self.active) {
        if (CGRectContainsPoint(self.frame, position)) {
            self.state = (self.state + 1) % 2;
            self.trigger();
            if (!self.toggle) {
                self.active = NO;
            }
        }
    }
}

@end
