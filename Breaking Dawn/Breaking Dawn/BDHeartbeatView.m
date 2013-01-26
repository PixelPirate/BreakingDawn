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

@end

@implementation BDHeartbeatView


- (id)init
{
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"heartbeat_isolated" ofType:@"mp3"]];
    
    self.heartPlayers = [NSMutableArray array];
    for(int i=0; i<10; i++) {
        AVAudioPlayer *heartPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        [self.heartPlayers addObject:heartPlayer];
    }

    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(tickHeart:) userInfo:nil repeats:YES];
    
    return self;
}

- (void)tickHeart:(NSTimer *)timer
{
    AVAudioPlayer *player = self.heartPlayers[self.currentSound];
    self.currentSound = (self.currentSound+1)%10;
    [player play];
}

@end
