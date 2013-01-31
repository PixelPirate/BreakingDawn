//
//  BDAudioContainer.m
//  Breaking Dawn
//
//  Created by Hendrik Klindworth on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDAudioContainer.h"

@interface BDAudioContainer ()

@property (readwrite, nonatomic) NSMutableArray *players;
@property (nonatomic) int currentPlayer;
@property (strong, readwrite, nonatomic) NSTimer *fadeTimer;
@property (assign, readwrite, nonatomic) float fadeToVolume;
@property (assign, readwrite, nonatomic) float fadeStepIncrement;
@property (assign, readwrite, nonatomic) NSTimeInterval fadeInterval;
@end

@implementation BDAudioContainer

-(id)initWithPath:(NSString *)path count:(int)count;
{
    self = [super init];
    if (self) {
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:path ofType:@"mp3"]];
        self.players = [NSMutableArray array];
        for(int i=0; i<count; i++) {
            AVAudioPlayer *heartPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
            heartPlayer.enableRate = YES;
            [self.players addObject:heartPlayer];
            self.fadeInterval = 0.016;
        }
    }
    return self;
}

-(AVAudioPlayer *)getPlayer;
{
    self.currentPlayer = (self.currentPlayer+1) % self.players.count;
    return self.players[self.currentPlayer];
}

- (void)fadeIn:(NSTimeInterval)duration
{
    NSAssert(self.players.count == 1, @"Fade effects only work with containers with no buffer. Initialize with count 1.");
    
    self.fadeToVolume = self.getPlayer.volume;
    [self.fadeTimer invalidate];
    [self.getPlayer stop];
    self.getPlayer.volume = 0.0;
    
    NSTimeInterval steps = duration / self.fadeInterval;
    self.fadeStepIncrement = (self.fadeToVolume - self.getPlayer.volume) / steps;
    
    [self.getPlayer play];
    
    self.fadeTimer = [NSTimer scheduledTimerWithTimeInterval:self.fadeInterval
                                                      target:self
                                                    selector:@selector(fadeInWithTimer:)
                                                    userInfo:[NSNumber numberWithFloat:self.fadeStepIncrement]
                                                     repeats:NO];
}

- (void)fadeInWithTimer:(NSTimer *)timer
{
    CGFloat volume = [timer.userInfo floatValue];
    if (volume < self.fadeToVolume) {
        self.getPlayer.volume = volume;
    } else {
        self.getPlayer.volume = self.fadeToVolume;
        return;
    }
    
    self.fadeTimer = [NSTimer scheduledTimerWithTimeInterval:self.fadeInterval
                                                      target:self
                                                    selector:@selector(fadeInWithTimer:)
                                                    userInfo:[NSNumber numberWithFloat:volume+self.fadeStepIncrement]
                                                     repeats:NO];
}

- (void)fadeOut:(NSTimeInterval)duration
{
    NSAssert(self.players.count == 1, @"Fade effects only work with containers with no buffer. Initialize with count 1.");
    
    if (!self.getPlayer.isPlaying) {
        return;
    }
    
    NSTimeInterval steps = duration / self.fadeInterval;
    self.fadeToVolume = 0.0;
    self.fadeStepIncrement = ((self.fadeToVolume - self.getPlayer.volume) / steps);
    
    [self.fadeTimer invalidate];
    self.fadeTimer = [NSTimer scheduledTimerWithTimeInterval:self.fadeInterval
                                                      target:self
                                                    selector:@selector(fadeOutWithTimer:)
                                                    userInfo:[NSNumber numberWithFloat:self.getPlayer.volume+self.fadeStepIncrement]
                                                     repeats:NO];
}

- (void)fadeOutWithTimer:(NSTimer *)timer
{
    CGFloat volume = [timer.userInfo floatValue];
    if (volume > 0.0) {
        self.getPlayer.volume = volume;
    } else {
        [self.getPlayer stop];
        return;
    }
    
    self.fadeTimer = [NSTimer scheduledTimerWithTimeInterval:self.fadeInterval
                                                      target:self
                                                    selector:@selector(fadeOutWithTimer:)
                                                    userInfo:[NSNumber numberWithFloat:volume+self.fadeStepIncrement]
                                                     repeats:NO];
}

@end
