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
    CGFloat stepRange = 60.0;
    static CGFloat rangeWalked = 0.0;
    
    CGPoint lastPosition = player.lastLocation;
    CGSize directionalDistance = CGSizeMake(lastPosition.x - position.x, lastPosition.y - position.y);
    CGFloat distance = ABS(sqrt(pow(directionalDistance.width, 2.0) + pow(directionalDistance.height, 2.0)));
    
    rangeWalked += distance;
    CGFloat steps = rangeWalked / stepRange;
    
    NSUInteger s = floor(steps);
    rangeWalked -= s * stepRange;
    
    CGPoint direction = CGPointMake(lastPosition.x - position.x, lastPosition.y - position.y);
    CGFloat maximalMovement = MAX(ABS(direction.x), ABS(direction.y));
    direction = CGPointMake(direction.x / maximalMovement, direction.y / maximalMovement);
    
    CGPoint unitY = CGPointMake(0, 1);
    double angle = atan2(unitY.y, unitY.x) - atan2(direction.y, direction.x);
    angle = angle * 180.0 / M_PI;
    angle = (angle < 0.0) ? angle + 360.0 : angle;
    
    NSArray *upright = @[[UIImage imageNamed:@"player00-move-back-01"], [UIImage imageNamed:@"player00-move-back-02"], [UIImage imageNamed:@"player00-move-back-03"]];
    NSArray *up = @[[UIImage imageNamed:@"player00-move-back-01"], [UIImage imageNamed:@"player00-move-back-02"], [UIImage imageNamed:@"player00-move-back-03"]];
    NSArray *upleft = @[[UIImage imageNamed:@"player00-move-back-01"], [UIImage imageNamed:@"player00-move-back-02"], [UIImage imageNamed:@"player00-move-back-03"]];
    NSArray *left = @[[UIImage imageNamed:@"player00-left"]];
    NSArray *leftdown = @[[UIImage imageNamed:@"player00-front-left"]];
    NSArray *down = @[[UIImage imageNamed:@"player00-move-front-01"], [UIImage imageNamed:@"player00-move-front-02"], [UIImage imageNamed:@"player00-move-front-03"]];
    NSArray *rightdown = @[[UIImage imageNamed:@"player00-front-right"]];
    NSArray *right = @[[UIImage imageNamed:@"player00-right"]];
    
    static NSUInteger index = 0;
    index += s;
    
    if (angle > 292.5 && angle < 337.5) {
        self.playerImageView.image = upright[index % upright.count];
    } else if (angle > 337.5 || angle < 22.5) {
        self.playerImageView.image = up[index % up.count];
    } else if (angle > 22.5 && angle < 67.5) {
        self.playerImageView.image = upleft[index % upleft.count];
    } else if (angle > 67.5 && angle < 112.5) {
        self.playerImageView.image = left[index % left.count];
    } else if (angle > 112.5 && angle < 157.5) {
        self.playerImageView.image = leftdown[index % leftdown.count];
    } else if (angle > 157.5 && angle < 202.5) {
        self.playerImageView.image = down[index % down.count];
    } else if (angle > 202.5 && angle < 247.5) {
        self.playerImageView.image = rightdown[index % rightdown.count];
    } else {
        self.playerImageView.image = right[index % right.count];
    }
    
    CGFloat scale = [[NSUserDefaults standardUserDefaults] floatForKey:@"Scale"];
    CGPoint center = position;
    center = CGPointApplyAffineTransform(center, CGAffineTransformMakeScale(scale, scale));
    self.center = center;
}

@end
