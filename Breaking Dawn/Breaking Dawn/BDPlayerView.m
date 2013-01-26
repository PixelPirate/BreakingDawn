//
//  BDPlayerView.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/25/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDPlayerView.h"
#import "BDPlayer.h"

@interface BDPlayerView () // Private setter

@property (strong, readwrite, nonatomic) BDPlayer *player;

@property (strong, readwrite, nonatomic) UIImage *playerImage;

@property (strong, readwrite, nonatomic) UIImageView *playerImageView;

@end



@implementation BDPlayerView

- (id)initWithPlayer:(BDPlayer *)player
{
    CGFloat scale = [[NSUserDefaults standardUserDefaults] floatForKey:@"Scale"];
    UIImage *playerImage = [UIImage imageNamed:@"player00"];
    
    self = [super initWithFrame:CGRectMake(0, 0, playerImage.size.width*scale, playerImage.size.height*scale)];
    if (self) {
        self.player = player;
        self.playerImage = playerImage;
        self.playerImageView = [[UIImageView alloc] initWithImage:self.playerImage];
        self.playerImageView.frame = self.bounds;
        CGPoint center = player.location;
        center = CGPointApplyAffineTransform(center, CGAffineTransformMakeScale(scale, scale));
        self.center = center;
        [self addSubview:self.playerImageView];
        
        self.player.delegate = self;
    }
    return self;
}

#pragma mark - BDPlayerDelegate implementation

- (void)playerDidMove:(BDPlayer *)player toPosition:(CGPoint)position
{
    CGFloat scale = [[NSUserDefaults standardUserDefaults] floatForKey:@"Scale"];
    CGPoint center = position;
    center = CGPointApplyAffineTransform(center, CGAffineTransformMakeScale(scale, scale));
    self.center = center;
}

@end
