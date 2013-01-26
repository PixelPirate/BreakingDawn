//
//  BDAmbientMusicController.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDAmbientMusicController.h"

@interface BDAmbientMusicController ()

@property (strong, readwrite, nonatomic) AVAudioPlayer *audioPlayer;

@end


@implementation BDAmbientMusicController

- (id)init
{
    self = [super init];
    if (self) {
        NSArray *files = @[@"Ambience-16.mp3", @"Ambience-17.mp3", @"Ambience-22.mp3"];
        NSURL *audioURL = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:files[arc4random_uniform(files.count)]];
        
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:nil];
        [self.audioPlayer prepareToPlay];
        self.audioPlayer.numberOfLoops = -1;
    }
    return self;
}

+ (BDAmbientMusicController *)sharedAmbientMusicController
{
    static BDAmbientMusicController *_sharedAmbientMusicController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedAmbientMusicController = [[BDAmbientMusicController alloc] init];
    });
    return _sharedAmbientMusicController;
}

- (void)play
{
    [self playFadeIn:YES];
}

- (void)playFadeIn:(BOOL)fadeIn
{
    [self.audioPlayer play];
}

- (void)stop
{
    [self stopFadeOut:YES];
}

- (void)stopFadeOut:(BOOL)fadeOut
{
    [self.audioPlayer stop];
}

@end
