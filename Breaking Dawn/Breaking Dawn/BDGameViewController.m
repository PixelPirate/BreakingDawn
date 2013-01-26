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
#import "BDSound.h"
#import "UIImage+UIImage_Extras.h"
#import "BDPostProcessingViewController.h"
#import "BDMob.h"
#import "BDHotspot.h"


@interface BDGameViewController ()

@property (strong, readwrite, nonatomic) BDPlayer *player;

@property (strong, readwrite, nonatomic) BDPlayerView *playerView;

@property (strong, readwrite, nonatomic) BDLevel *currentLevel;

@property (strong, readwrite, nonatomic) BDLevelView *currentLevelView;

@property (strong, readwrite, nonatomic) BDSound *sound;

@property (assign, readwrite, nonatomic) CGPoint lastTouchLocation;

@property (strong, readwrite, nonatomic) BDPostProcessingViewController *postProcessingViewController;

@property (strong, readwrite, nonatomic) NSTimer *gameTimer;

- (void)tickWithTimer:(NSTimer *)timer;

- (void)adrenalinChanged;

- (void)gameDidEnd;

@end


@implementation BDGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1/25.0
                                                          target:self
                                                        selector:@selector(tickWithTimer:)
                                                        userInfo:nil
                                                         repeats:YES];
        self.lastTouchLocation = CGPointZero;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentLevel = [BDLevel levelNamed:@"map00"];
    self.currentLevelView = [[BDLevelView alloc] initWithLevel:self.currentLevel];
    self.player = [[BDPlayer alloc] initWithPosition:self.currentLevel.spawn];
    self.playerView = [[BDPlayerView alloc] initWithPlayer:self.player];
    __weak id s = self;
    self.player.adrenalinHandler = ^{
        [s adrenalinChanged];
    };
    self.sound = [[BDSound alloc] initWithPlayer:self.player];
    
    self.postProcessingViewController = [[BDPostProcessingViewController alloc] initWithNibName:nil bundle:nil];
    self.postProcessingViewController.currentLevelView = self.currentLevelView;
    
    UIView *gameView = [[UIView alloc] initWithFrame:self.currentLevelView.bounds];
    [gameView addSubview:self.currentLevelView];
    [self.currentLevelView.playerLayer addSubview:self.playerView];
    
    
    CGSize applicationSize = [[UIScreen mainScreen] applicationFrame].size;
    gameView.frame = CGRectOffset(gameView.frame, -self.playerView.center.x+applicationSize.width/2.0, -self.playerView.center.y+applicationSize.height/2.0);
    
    self.view = gameView;
    
    [self.view addSubview:self.postProcessingViewController.view];
    self.postProcessingViewController.view.frame = CGRectMake(-self.view.frame.origin.x,
                                                              -self.view.frame.origin.y,
                                                              [UIScreen mainScreen].applicationFrame.size.width,
                                                              [UIScreen mainScreen].applicationFrame.size.height);
    
    self.lastTouchLocation = CGPointZero;
    
    
    
    [NSTimer scheduledTimerWithTimeInterval:3.0
                                     target:self.postProcessingViewController
                                   selector:@selector(static)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)pushTouch:(UITouch *)touch
{
    // Direction of player to touch
    CGPoint location = [touch locationInView:self.view];
    
    CGPoint direction = CGPointMake(self.playerView.center.x - location.x, self.playerView.center.y - location.y);
    
    CGSize max = [[UIScreen mainScreen] applicationFrame].size;
    
    max = CGSizeApplyAffineTransform(max, CGAffineTransformMakeScale(0.5, 0.5));
    CGPoint normalizedDirection = CGPointMake(direction.x / max.width, direction.y / max.height);
    
    BOOL precitionControlls = [[NSUserDefaults standardUserDefaults] boolForKey:@"PrecitionControlls"];
    if (!precitionControlls) {
        CGFloat maximalMovement = MAX(ABS(normalizedDirection.x), ABS(normalizedDirection.y));
        normalizedDirection = CGPointMake(normalizedDirection.x / maximalMovement, normalizedDirection.y / maximalMovement);
    }
    
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
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.lastTouchLocation = CGPointZero;
}

- (void)tickWithTimer:(NSTimer *)timer
{
    CGPoint movement = self.lastTouchLocation;
    
    float gameSpeed = 62.5/25.0;
    
    // Move the player
    if (!CGPointEqualToPoint(movement, CGPointZero)) {
        CGFloat walkingSpeed = [[NSUserDefaults standardUserDefaults] floatForKey:@"WalkingSpeed"] * gameSpeed;
        movement = CGPointApplyAffineTransform(movement, CGAffineTransformMakeScale(walkingSpeed, walkingSpeed));
        CGPoint newLocation = CGPointApplyAffineTransform(self.player.location,
                                                          CGAffineTransformMakeTranslation(-movement.x, -movement.y));
        if ([self.currentLevel canMoveFrom:self.player.location to:newLocation]) {
            self.player.location = newLocation;
        }
    }
    
    // Hotspots
    for (BDHotspot *hotspot in self.currentLevel.hotspots) {
        [hotspot test:self.player.location];
    }
    
    // Check light amount recieved by the player
    CGFloat luminance = 0.0;
        for (NSDictionary *light in self.currentLevel.lights) {
            CGPoint lightPosition = CGPointZero;
            CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(light), &lightPosition);
            CGFloat fakeRadius = 80.0 * (MAX(self.currentLevel.lightScale, 0.3));
            
            BOOL(^PointInsideCircle)(CGPoint p, CGPoint center, CGFloat radius) = ^(CGPoint p, CGPoint center, CGFloat radius) {
                if ((pow(p.x-center.x, 2.0) + pow(p.y - center.y, 2.0)) < pow(radius, 2.0)) {
                    return YES;
                } else {
                    return NO;
                }
            };
            
            if (PointInsideCircle(CGPointMake(self.player.location.x, self.player.location.y), lightPosition, fakeRadius)) {
                //canMove = NO;
                //*stop = YES;
                CGSize distance = CGSizeMake(self.player.location.x - lightPosition.x, self.player.location.y - lightPosition.y);
                CGFloat length = sqrt(pow(distance.width, 2.0) + pow(distance.height, 2.0));
                
                luminance = 1.0 - ((length + 0.01) / 80.0); // 1 means dark, 0 means bright
            }
        }
    [self.player updateAdrenalin:luminance];
//    CGFloat luminance = 0.0; // 1 means dark, 0 means bright
//    [light getRed:NULL green:NULL blue:NULL alpha:&luminance];
//    [self.player updateAdrenalin:1.0 - luminance];
    
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
    
    // Center the postprocessing view to the screen
    self.postProcessingViewController.view.frame = CGRectMake(-self.view.frame.origin.x,
                                                              -self.view.frame.origin.y,
                                                              [UIScreen mainScreen].applicationFrame.size.width,
                                                              [UIScreen mainScreen].applicationFrame.size.height);
    
    // Mobs
    CGFloat speed = [[NSUserDefaults standardUserDefaults] floatForKey:@"MobWalkingSpeed"] * gameSpeed;
    for (BDMob *mob in self.currentLevel.mobs) {
        BOOL canReach = [self.currentLevel canMoveFrom:mob.location to:self.player.location withLightLimit:0.0];
        if (canReach) {
            CGPoint direction = CGPointMake(mob.location.x - self.player.location.x, mob.location.y - self.player.location.y);
            CGFloat maximalMovement = MAX(ABS(direction.x), ABS(direction.y));
            direction = CGPointMake(direction.x / maximalMovement, direction.y / maximalMovement);
            direction = CGPointApplyAffineTransform(direction, CGAffineTransformMakeScale(speed, speed));
            mob.location = CGPointMake(mob.location.x - direction.x, mob.location.y - direction.y);
        }
    }
    
    // Check mob vs player collisions
    for (BDMob *mob in self.currentLevel.mobs) {
        CGRect size = CGRectMake(0, 0, 40, 40);
        CGRect mobRect = CGRectOffset(size, mob.location.x, mob.location.y);
        CGRect playerRect = CGRectOffset(size, self.player.location.x, self.player.location.y);
        if (CGRectIntersectsRect(mobRect, playerRect)) {
            [self gameDidEnd];
        }
    }
}

- (void)adrenalinChanged
{
    // Manipulate ambience
    self.currentLevelView.surfaceLayer.alpha = (1.0 - self.player.adrenalin) - 0.5;
    //CGFloat scale = self.currentLevelView.lightScale;
    //NSLog(@"%f %f", scale, self.player.luminanceDelta);
    //self.currentLevelView.lightScale = scale + self.player.luminanceDelta;
    
    self.currentLevelView.lightScale = (1.0 - self.player.adrenalin);
    
//    if (self.player.adrenalin > 0.3) {
//        self.currentLevelView.lightScale -= 0.003;
//        if (self.currentLevelView.lightScale < 0.0) {
//            self.currentLevelView.lightScale = 0.0;
//        }
//    } else {
//        self.currentLevelView.lightScale += 0.004;
//        if (self.currentLevelView.lightScale > 1.0) {
//            self.currentLevelView.lightScale = 1.0;
//        }
//    }
    
    self.currentLevelView.pulse = self.player.adrenalin;
}

- (void)gameDidEnd
{
    [self.gameTimer invalidate];
    self.player.adrenalinHandler = nil;
    self.currentLevelView.pulse = 10.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
