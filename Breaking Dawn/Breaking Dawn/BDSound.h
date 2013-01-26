//
//  BDHeartbeatView.h
//  Breaking Dawn
//
//  Created by Hendrik Klindworth on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDPlayer.h"

@interface BDSound : NSObject

@property (nonatomic) float bpm;

- (id)initWithPlayer:(BDPlayer *)player;

@end
