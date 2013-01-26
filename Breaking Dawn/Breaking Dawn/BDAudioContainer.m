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

@end

@implementation BDAudioContainer

-(id)initWithPath:(NSString *)path count:(int)count;
{
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:path ofType:@"mp3"]];    
    self.players = [NSMutableArray array];
    for(int i=0; i<count; i++) {
        AVAudioPlayer *heartPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        heartPlayer.enableRate = YES;
        [self.players addObject:heartPlayer];
    }
    
    return self;
}

-(AVAudioPlayer *)getPlayer;
{
    self.currentPlayer = (self.currentPlayer+1) % [self.players count];
    return self.players[self.currentPlayer];
}

@end
