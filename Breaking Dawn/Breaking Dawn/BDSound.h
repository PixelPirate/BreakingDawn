//
//  BDHeartbeatView.h
//  Breaking Dawn
//
//  Created by Hendrik Klindworth on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BDPlayer;

enum {
    SOUND_GAME_OVER,
    SOUND_LIGHT_EXPLODE,
    SOUND_LIGHT_FLICKER,
    SOUND_LIGHT_SWITCH,
} sounds;

@interface BDSound : NSObject

@property (nonatomic) float bpm;

+ (BDSound *)sharedSound;

//- (id)initWithPlayer:(BDPlayer *)player;

- (void)playSound:(int)soundId;

- (void)playMonster:(int)soundId;

- (void)beginHeartbeatForPlayer:(BDPlayer *)player;

- (void)endHeartbeat;

- (void)playCredits;

- (void)stopCredits;

@end
