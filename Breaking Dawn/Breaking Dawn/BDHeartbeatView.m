//
//  BDHeartbeatView.m
//  Breaking Dawn
//
//  Created by Hendrik Klindworth on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDHeartbeatView.h"
#import <AVFoundation/AVFoundation.h>

@interface BDHeartbeatView ()

@property (readwrite, nonatomic) NSMutableArray *heartPlayers;
@property (nonatomic) int currentSound;
@property (nonatomic) float bpm;

@end

@implementation BDHeartbeatView


- (id)init
{
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"heartbeat_isolated" ofType:@"mp3"]];
    
    self.bpm = 120;
    
    self.heartPlayers = [NSMutableArray array];
    for(int i=0; i<10; i++) {
        AVAudioPlayer *heartPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        heartPlayer.enableRate = YES;
        [self.heartPlayers addObject:heartPlayer];
    }

    [NSTimer scheduledTimerWithTimeInterval:60/self.bpm target:self selector:@selector(tickHeart:) userInfo:nil repeats:YES];
    
    return self;
}

- (void)tickHeart:(NSTimer *)timer
{
    AVAudioPlayer *player = self.heartPlayers[self.currentSound];
    self.currentSound = (self.currentSound+1)%10;
    // Speed between 1 and 2, depending on bpm (from 60 to 180)
    player.rate = fmax(fmin(1 + (self.bpm-60)/(180-60), 2), 1);
    [player play];
}

@end
