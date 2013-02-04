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

@property (strong, readwrite, nonatomic) NSArray *upright;

@property (strong, readwrite, nonatomic) NSArray *up;

@property (strong, readwrite, nonatomic) NSArray *upleft;

@property (strong, readwrite, nonatomic) NSArray *left;

@property (strong, readwrite, nonatomic) NSArray *leftdown;

@property (strong, readwrite, nonatomic) NSArray *down;

@property (strong, readwrite, nonatomic) NSArray *rightdown;

@property (strong, readwrite, nonatomic) NSArray *right;

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
        
        self.upright = @[[UIImage imageNamed:@"player00-move-back-right-01"],
                         [UIImage imageNamed:@"player00-move-back-right-02"],
                         [UIImage imageNamed:@"player00-move-back-right-03"]];
        self.up = @[[UIImage imageNamed:@"player00-move-back-01"],
                    [UIImage imageNamed:@"player00-move-back-02"],
                    [UIImage imageNamed:@"player00-move-back-03"]];
        self.upleft = @[[UIImage imageNamed:@"player00-move-back-left-01"],
                        [UIImage imageNamed:@"player00-move-back-left-02"],
                        [UIImage imageNamed:@"player00-move-back-left-03"]];
        self.left = @[[UIImage imageNamed:@"player00-move-left-01"],
                      [UIImage imageNamed:@"player00-move-left-02"],
                      [UIImage imageNamed:@"player00-move-left-03"]];
        self.leftdown = @[[UIImage imageNamed:@"player00-move-front-left-01"],
                          [UIImage imageNamed:@"player00-move-front-left-02"],
                          [UIImage imageNamed:@"player00-move-front-left-03"]];
        self.down = @[[UIImage imageNamed:@"player00-move-front-01"],
                      [UIImage imageNamed:@"player00-move-front-02"],
                      [UIImage imageNamed:@"player00-move-front-03"]];
        self.rightdown = @[[UIImage imageNamed:@"player00-move-front-right-01"],
                           [UIImage imageNamed:@"player00-move-front-right-02"],
                           [UIImage imageNamed:@"player00-move-front-right-03"]];
        self.right = @[[UIImage imageNamed:@"player00-move-right-01"],
                       [UIImage imageNamed:@"player00-move-right-02"],
                       [UIImage imageNamed:@"player00-move-right-03"]];
    }
    return self;
}

#pragma mark - BDPlayerDelegate implementation

- (void)playerDidMove:(BDPlayer *)player toPosition:(CGPoint)position
{
    CGFloat stepRange = 10.0;
    static CGFloat rangeWalked = 0.0;
    
    CGPoint lastPosition = player.lastLocation;
    CGSize directionalDistance = CGSizeMake(lastPosition.x - position.x, lastPosition.y - position.y);
    CGFloat distance = ABS(sqrt(pow(directionalDistance.width, 2.0) + pow(directionalDistance.height, 2.0)));
    
    rangeWalked += distance;
    CGFloat steps = rangeWalked / stepRange;
    
    NSUInteger s = floor(steps);
    rangeWalked -= s * stepRange;
    
    CGPoint direction = player.direction;
    CGFloat maximalMovement = MAX(ABS(direction.x), ABS(direction.y));
    direction = CGPointMake(direction.x / maximalMovement, direction.y / maximalMovement);
    
    CGPoint unitY = CGPointMake(0, 1);
    double angle = atan2(unitY.y, unitY.x) - atan2(direction.y, direction.x);
    angle = angle * 180.0 / M_PI;
    angle = (angle < 0.0) ? angle + 360.0 : angle;
    
    static NSUInteger index = 0;
    index += s;
    
    if (angle > 292.5 && angle < 337.5) {
        self.playerImageView.image = _upright[index % _upright.count];
    } else if (angle > 337.5 || angle < 22.5) {
        self.playerImageView.image = _up[index % _up.count];
    } else if (angle > 22.5 && angle < 67.5) {
        self.playerImageView.image = _upleft[index % _upleft.count];
    } else if (angle > 67.5 && angle < 112.5) {
        self.playerImageView.image = _left[index % _left.count];
    } else if (angle > 112.5 && angle < 157.5) {
        self.playerImageView.image = _leftdown[index % _leftdown.count];
    } else if (angle > 157.5 && angle < 202.5) {
        self.playerImageView.image = _down[index % _down.count];
    } else if (angle > 202.5 && angle < 247.5) {
        self.playerImageView.image = _rightdown[index % _rightdown.count];
    } else {
        self.playerImageView.image = _right[index % _right.count];
    }
    
    CGFloat scale = [[NSUserDefaults standardUserDefaults] floatForKey:@"Scale"];
    CGPoint center = position;
    center = CGPointApplyAffineTransform(center, CGAffineTransformMakeScale(scale, scale));
    self.center = center;
}

@end
