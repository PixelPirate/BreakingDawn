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

static BDSound *instance;

@interface BDSound ()

@property (strong, readwrite, nonatomic) BDPlayer *player;

@property (readwrite, nonatomic) BDAudioContainer *heart;
@property (readwrite, nonatomic) NSMutableArray *monsters;
@property (readwrite, nonatomic) NSMutableArray *sounds;
@property (readwrite, nonatomic) NSMutableArray *blockedMonsterSoundIDs;

@end

@implementation BDSound

+ (BDSound *)getInstance
{
    return instance;
}

- (id)initWithPlayer:(BDPlayer *)player
{
    self.player = player;
    
    self.bpm = 60 + self.player.adrenalin*120;
    
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
    [self.sounds addObject:[[BDAudioContainer alloc] initWithPath:@"Flickering_Light_Electric_Buzz_5_700" count:2]];
    [self.sounds addObject:[[BDAudioContainer alloc] initWithPath:@"Exploding_Light_Bulb_1_200" count:2]];
    [self.sounds addObject:[[BDAudioContainer alloc] initWithPath:@"Light_Switch_0_250" count:2]];
    

    [NSTimer scheduledTimerWithTimeInterval:60/self.bpm target:self selector:@selector(tickHeart:) userInfo:nil repeats:NO];
    
    instance = self;
    return self;
}

- (void)playMonster:(int)soundId
{
    BOOL simultanousMonsterSounds = [[NSUserDefaults standardUserDefaults] boolForKey:@"SimultanousMonsterSounds"];
    AVAudioPlayer *player = [self.monsters[soundId] getPlayer];
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
    self.bpm = 60 + self.player.adrenalin*120;

    // Schedule next timer
    [NSTimer scheduledTimerWithTimeInterval:60/self.bpm target:self selector:@selector(tickHeart:) userInfo:nil repeats:NO];

    
    AVAudioPlayer *player = [self.heart getPlayer];

    // Speed between 1 and 2, depending on bpm (from 60 to 180)
    player.rate = fmax(fmin(1 + (self.bpm-60)/(180-60), 2), 1);
    [player play];
}

@end
