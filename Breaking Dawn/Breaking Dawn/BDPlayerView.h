//
//  BDPlayerView.h
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/25/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDPlayer.h"

@interface BDPlayerView : UIView<BDPlayerDelegate>

@property (strong, readonly, nonatomic) BDPlayer *player;

- (id)initWithPlayer:(BDPlayer *)player;

@end
