//
//  BDHeartbeatView.h
//  Breaking Dawn
//
//  Created by Hendrik Klindworth on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDPlayer.h"

enum {
    SOUND_GAME_OVER,
    SOUND_LIGHT_EXPLODE,
    SOUND_LIGHT_FLICKER,
    SOUND_LIGHT_SWITCH,
    
} sounds;

@interface BDSound : NSObject

@property (nonatomic) float bpm;

+ (BDSound *)getInstance;

- (id)initWithPlayer:(BDPlayer *)player;

- (void)playSound:(int)soundId;

- (void)playMonster:(int)soundId;

@end
