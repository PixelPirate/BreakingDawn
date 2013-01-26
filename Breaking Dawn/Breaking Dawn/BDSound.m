//
//  BDHeartbeatView.m
//  Breaking Dawn
//
//  Created by Hendrik Klindworth on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDSound.h"
#import "BDAudioContainer.h"
#import <AVFoundation/AVFoundation.h>

@interface BDSound ()

@property (strong, readwrite, nonatomic) BDPlayer *player;

@property (readwrite, nonatomic) BDAudioContainer *heart;
@property (nonatomic) int currentSound;

@end

@implementation BDSound


- (id)initWithPlayer:(BDPlayer *)player
{
    self.player = player;
    
    self.bpm = 60 + self.player.adrenalin*120;
    
    self.heart = [[BDAudioContainer alloc] initWithPath:@"heartbeat_isolated" count:10];

    [NSTimer scheduledTimerWithTimeInterval:60/self.bpm target:self selector:@selector(tickHeart:) userInfo:nil repeats:NO];
    
    return self;
}

- (void)tickHeart:(NSTimer *)timer
{
    self.bpm = 60 + self.player.adrenalin*120;

    // Schedule next timer
    [NSTimer scheduledTimerWithTimeInterval:60/self.bpm target:self selector:@selector(tickHeart:) userInfo:nil repeats:NO];

    
    AVAudioPlayer *player = [self.heart getPlayer];

    // Speed between 1 and 2, depending on bpm (from 60 to 180)
    player.rate = fmax(fmin(1 + (self.bpm-60)/(180-60), 2), 1);
    [player play];
}

@end
