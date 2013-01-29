//
//  BDHeartbeatView.m
//  Breaking Dawn
//
//  Created by Hendrik Klindworth on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDSound.h"
#import "BDAudioContainer.h"
#import "BDPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface BDSound ()

@property (strong, readwrite, nonatomic) BDPlayer *player;
@property (strong, readwrite, nonatomic) NSTimer *heartbeatTimer;
@property (readwrite, nonatomic) BDAudioContainer *heart;
@property (readwrite, nonatomic) NSMutableArray *monsters;
@property (readwrite, nonatomic) NSMutableArray *sounds;
@property (readwrite, nonatomic) NSMutableArray *blockedMonsterSoundIDs;

@end

@implementation BDSound

+ (BDSound *)sharedSound
{
    static BDSound *_sharedSound = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSound = [[BDSound alloc] init];
    });
    return _sharedSound;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.bpm = 60.0;
        self.heart = [[BDAudioContainer alloc] initWithPath:@"heartbeat_isolated_0_700" count:10];
        
        self.monsters = [NSMutableArray array];
        BOOL simultanousMonsterSounds = [[NSUserDefaults standardUserDefaults] boolForKey:@"SimultanousMonsterSounds"];
        NSUInteger count = (simultanousMonsterSounds) ? 2 : 1;
        [self.monsters addObject:[[BDAudioContainer alloc] initWithPath:@"Monster_Awakes1" count:count]];
        [self.monsters addObject:[[BDAudioContainer alloc] initWithPath:@"Monster_Awakes1+2" count:count]];
        [self.monsters addObject:[[BDAudioContainer alloc] initWithPath:@"Monster_Awakes2" count:count]];
        [self.monsters addObject:[[BDAudioContainer alloc] initWithPath:@"Monster_Awakes2+3" count:count]];
        [self.monsters addObject:[[BDAudioContainer alloc] initWithPath:@"Monster_Awakes3" count:count]];
	    
        self.sounds = [NSMutableArray array];
        [self.sounds addObject:[[BDAudioContainer alloc] initWithPath:@"Game_Over_Scream" count:2]];
        [self.sounds addObject:[[BDAudioContainer alloc] initWithPath:@"Exploding_Light_Bulb_1_200" count:2]];
        [self.sounds addObject:[[BDAudioContainer alloc] initWithPath:@"Flickering_Light_Electric_Buzz_5_700" count:2]];
        [self.sounds addObject:[[BDAudioContainer alloc] initWithPath:@"Light_Switch_0_250" count:2]];
    }
    return self;
}

- (void)playMonster:(int)soundId
{
    BOOL simultanousMonsterSounds = [[NSUserDefaults standardUserDefaults] boolForKey:@"SimultanousMonsterSounds"];
    AVAudioPlayer *player = [self.monsters[soundId] getPlayer];
    player.volume = 0.5;
    if (!simultanousMonsterSounds && player.isPlaying) return;
    [player play];
}

- (void)playSound:(int)soundId
{
    AVAudioPlayer *player = [self.sounds[soundId] getPlayer];
    [player play];
}


- (void)tickHeart:(NSTimer *)timer
{
    self.bpm = 60.0 + self.player.adrenalin * 120.0;
    
    // Schedule next timer
    self.heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:(60.0 / self.bpm)
                                                           target:self
                                                         selector:@selector(tickHeart:)
                                                         userInfo:nil
                                                          repeats:NO];
    
    AVAudioPlayer *player = [self.heart getPlayer];
    
    // Speed between 1 and 2, depending on bpm (from 60 to 180)
    player.rate = fmax(fmin(1.0 + (self.bpm - 60.0) / (180.0 - 60.0), 2.0), 1.0);
    [player play];
}

- (void)beginHeartbeatForPlayer:(BDPlayer *)player
{
    self.player = player;
    self.bpm = 60 + self.player.adrenalin*120;
    self.heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:60.0/self.bpm
                                                           target:self
                                                         selector:@selector(tickHeart:)
                                                         userInfo:nil
                                                          repeats:NO];
}

- (void)endHeartbeat
{
    self.player = nil;
    self.bpm = 60.0;
    [self.heartbeatTimer invalidate];
}

@end
