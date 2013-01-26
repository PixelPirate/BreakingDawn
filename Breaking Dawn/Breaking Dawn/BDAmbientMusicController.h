//
//  BDAmbientMusicController.h
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface BDAmbientMusicController : NSObject

@property (strong, readonly, nonatomic) AVAudioPlayer *audioPlayer;

+ (BDAmbientMusicController *)sharedAmbientMusicController;

- (void)play;
- (void)playFadeIn:(BOOL)fadeIn;

- (void)stop;
- (void)stopFadeOut:(BOOL)fadeOut;

@end
