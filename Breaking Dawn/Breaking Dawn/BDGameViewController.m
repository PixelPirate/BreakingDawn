//
//  BDGameViewController.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/25/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDGameViewController.h"
#import "BDLevelView.h"
#import "BDLevel.h"
#import "BDPlayer.h"
#import "BDPlayerView.h"


@interface BDGameViewController ()

@property (strong, readwrite, nonatomic) BDPlayer *player;

@property (strong, readwrite, nonatomic) BDPlayerView *playerView;

@property (strong, readwrite, nonatomic) BDLevel *currentLevel;

@property (strong, readwrite, nonatomic) NSMutableArray *moveEventQueue;

@property (assign, readwrite, nonatomic) CGPoint lastTouchLocation;

- (void)tickWithTimer:(NSTimer *)timer;

@end


@implementation BDGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.moveEventQueue = [NSMutableArray array];
        [NSTimer scheduledTimerWithTimeInterval:0.016 target:self selector:@selector(tickWithTimer:) userInfo:nil repeats:YES];
        self.lastTouchLocation = CGPointZero;
        //CGPointMake([UIScreen mainScreen].applicationFrame.size.width/2.0,
          //                                   [UIScreen mainScreen].applicationFrame.size.height/2.0);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.currentLevel = [BDLevel levelNamed:@"Level0"];
    BDLevelView *levelView = [[BDLevelView alloc] initWithLevel:self.currentLevel];
    self.player = [[BDPlayer alloc] initWithPosition:self.currentLevel.spawn];
    self.playerView = [[BDPlayerView alloc] initWithPlayer:self.player];
    
    UIView *gameView = [[UIView alloc] initWithFrame:levelView.bounds];
    [gameView addSubview:levelView];
    [gameView insertSubview:self.playerView aboveSubview:levelView];
    
    
    CGSize applicationSize = [[UIScreen mainScreen] applicationFrame].size;
    gameView.frame = CGRectOffset(gameView.frame, -self.playerView.center.x+applicationSize.width/2.0, -self.playerView.center.y+applicationSize.height/2.0);
    
    self.view = gameView;
    
    self.lastTouchLocation = CGPointZero;
    //[self.view convertPoint:self.playerView.center fromView:self.playerView];
}

- (void)pushTouch:(UITouch *)touch
{
    // Direction of player to touch
    CGPoint location = [touch locationInView:self.view];
    
    CGPoint direction = CGPointMake(self.playerView.center.x - location.x, self.playerView.center.y - location.y);
    
    CGSize max = [[UIScreen mainScreen] applicationFrame].size;
    
    max = CGSizeApplyAffineTransform(max, CGAffineTransformMakeScale(0.5, 0.5));
    CGPoint normalizedDirection = CGPointMake(direction.x / max.width, direction.y / max.height);
    
    //[self.moveEventQueue addObject:[NSValue valueWithCGPoint:normalizedDirection]];
    self.lastTouchLocation = normalizedDirection;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self pushTouch:touches.anyObject];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self pushTouch:touches.anyObject];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.lastTouchLocation = CGPointZero;
    //[self.view convertPoint:self.playerView.center fromView:self.playerView];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.lastTouchLocation = CGPointZero;
    
    //[self.view convertPoint:self.playerView.center fromView:self.playerView];
}

- (void)tickWithTimer:(NSTimer *)timer
{
    CGPoint movement = self.lastTouchLocation;
    
    // Move the player
    CGPoint newLocation = CGPointApplyAffineTransform(self.player.location, CGAffineTransformMakeTranslation(-movement.x, -movement.y));
    //if ([self.currentLevel canMoveFrom:self.player.location to:newLocation]) {
        self.player.location = newLocation;
    //}
    
    // Center the game view to the players location
    CGFloat b = self.playerView.center.x;
    CGFloat a = [UIScreen mainScreen].applicationFrame.size.width / 2.0;
    CGFloat x = -b + a;
    CGFloat u = self.playerView.center.y;
    CGFloat v = [UIScreen mainScreen].applicationFrame.size.height / 2.0;
    CGFloat y = -u + v;
    self.view.frame = CGRectMake(x,
                                 y,
                                 self.view.frame.size.width,
                                 self.view.frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
