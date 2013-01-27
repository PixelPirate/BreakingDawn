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
#import "BDAmbientMusicController.h"
#import "BDGameOverViewController.h"
#import "BDGameWinViewController.h"


@interface BDGameViewController ()

@property (strong, readwrite, nonatomic) BDPlayer *player;

@property (strong, readwrite, nonatomic) BDPlayerView *playerView;

@property (strong, readwrite, nonatomic) BDLevel *currentLevel;

@property (strong, readwrite, nonatomic) BDLevelView *currentLevelView;

@property (strong, readwrite, nonatomic) BDSound *sound;

@property (assign, readwrite, nonatomic) CGPoint lastTouchLocation;

@property (strong, readwrite, nonatomic) BDPostProcessingViewController *postProcessingViewController;

@property (strong, readwrite, nonatomic) NSTimer *gameTimer;

@property (strong, readwrite, nonatomic) NSTimer *staticTimer;

@property (strong, readwrite, nonatomic) BDAmbientMusicController *ambientMusicController;

@property (strong, readwrite, nonatomic) BDGameOverViewController *gameOverViewController;

@property (strong, readwrite, nonatomic) BDGameWinViewController *gameWinViewController;

- (void)tickWithTimer:(NSTimer *)timer;

- (void)adrenalinChanged;

- (void)gameDidEnd;

@end


@implementation BDGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.lastTouchLocation = CGPointZero;
        
        self.ambientMusicController = [BDAmbientMusicController sharedAmbientMusicController];
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
    
    [self.currentLevelView.playerLayer addSubview:self.playerView];
    [self.view addSubview:self.currentLevelView];
    
    self.lastTouchLocation = CGPointZero;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.postProcessingViewController = [[BDPostProcessingViewController alloc] initWithNibName:nil bundle:nil];
    self.postProcessingViewController.currentLevelView = self.currentLevelView;
    self.postProcessingViewController.view.frame = self.view.bounds;
    //    self.postProcessingViewController.view.frame = CGRectMake(-self.view.frame.origin.x,
    //                                                              -self.view.frame.origin.y,
    //                                                              [UIScreen mainScreen].applicationFrame.size.width,
    //                                                              [UIScreen mainScreen].applicationFrame.size.height);
    [self.view addSubview:self.postProcessingViewController.view];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.staticTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                     target:self.postProcessingViewController
                                   selector:@selector(static)
                                   userInfo:nil
                                    repeats:YES];
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:[[NSUserDefaults standardUserDefaults] floatForKey:@"DrawRate"]
                                                      target:self
                                                    selector:@selector(tickWithTimer:)
                                                    userInfo:nil
                                                     repeats:YES];
    [self.ambientMusicController play];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.postProcessingViewController.view removeFromSuperview];
    self.postProcessingViewController.currentLevelView = nil;
    self.postProcessingViewController = nil;
}

- (void)pushTouch:(UITouch *)touch
{
    // Direction of player to touch
    CGPoint location = [touch locationInView:self.currentLevelView];
    
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
        
        // Try to move at least in one the directions
        CGPoint pushBack[3] = { CGPointMake(-1, -1), CGPointMake(0, -1), CGPointMake(-1, 0), };
        for (NSUInteger i = 0; i < 3; i++) {
            newLocation = CGPointApplyAffineTransform(self.player.location,
                                                      CGAffineTransformMakeTranslation(movement.x*pushBack[i].x,
                                                                                       movement.y*pushBack[i].y));
            if ([self.currentLevel isFreeX:newLocation.x andY:newLocation.y]) {
                self.player.location = newLocation;
                break;
            }
        }
        
        self.player.direction = movement;
    }
    
    // Hotspots
    for (BDHotspot *hotspot in self.currentLevel.hotspots) {
        [hotspot test:self.player.location];
    }
    
    // Check light amount recieved by the player
    CGFloat luminance = 0.0;
    for (NSValue *light in self.currentLevel.lights) {
        CGPoint lightPosition = [light CGPointValue];
        CGFloat fakeRadius = 80.0 * (MAX(self.currentLevel.lightScale, 0.45));
        
        BOOL(^PointInsideCircle)(CGPoint p, CGPoint center, CGFloat radius) = ^(CGPoint p, CGPoint center, CGFloat radius) {
            if ((pow(p.x-center.x, 2.0) + pow(p.y - center.y, 2.0)) < pow(radius, 2.0)) {
                return YES;
            } else {
                return NO;
            }
        };
        
        if (PointInsideCircle(CGPointMake(self.player.location.x, self.player.location.y), lightPosition, fakeRadius)) {
            CGSize distance = CGSizeMake(self.player.location.x - lightPosition.x, self.player.location.y - lightPosition.y);
            CGFloat length = sqrt(pow(distance.width, 2.0) + pow(distance.height, 2.0));
            
            luminance = 1.0 - ((length + 0.01) / 80.0); // 1 means dark, 0 means bright
        }
    }
    [self.player updateAdrenalin:luminance];
    self.currentLevelView.frame = CGRectMake(-self.playerView.center.x+self.view.bounds.size.width/2.0,
                                             -self.playerView.center.y+self.view.bounds.size.height/2.0,
                                             self.currentLevelView.frame.size.width,
                                             self.currentLevelView.frame.size.height);
    
    // Mobs
    CGFloat speed = [[NSUserDefaults standardUserDefaults] floatForKey:@"MobWalkingSpeed"] * gameSpeed;
    for (BDMob *mob in self.currentLevel.mobs) {
        // Skip if distance > 400
        CGFloat dx = mob.location.x - self.player.location.x;
        CGFloat dy = mob.location.y - self.player.location.y;
        if(sqrt(dx*dx + dy*dy) > 400) continue;
        
        BOOL canReach = [self.currentLevel canMoveFrom:mob.location to:self.player.location];
        if (canReach) {
            canReach = [self.currentLevel noLightsFrom:mob.location to:self.player.location];
            if(canReach) {
                CGPoint direction = CGPointMake(mob.location.x - self.player.location.x, mob.location.y - self.player.location.y);
                CGFloat maximalMovement = MAX(ABS(direction.x), ABS(direction.y));
                direction = CGPointMake(direction.x / maximalMovement, direction.y / maximalMovement);
                direction = CGPointApplyAffineTransform(direction, CGAffineTransformMakeScale(speed, speed));
                mob.location = CGPointMake(mob.location.x - direction.x, mob.location.y - direction.y);
                [[BDSound getInstance] playMonster:arc4random_uniform(5)];
            }
        }
    }
    
    // Check mob vs player collisions
    for (BDMob *mob in self.currentLevel.mobs) {
        CGRect size = CGRectMake(0, 0, 40, 40);
        CGRect mobRect = CGRectOffset(size, mob.location.x, mob.location.y);
        CGRect playerRect = CGRectOffset(size, self.player.location.x, self.player.location.y);
        if (CGRectIntersectsRect(mobRect, playerRect)) {
            BOOL godeMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"GodMode"];
            if (!godeMode) {
                [self gameDidEnd];
            }
        }
    }
}

- (void)adrenalinChanged
{
    // Manipulate ambience
    self.currentLevelView.surfaceLayer.alpha = (1.0 - self.player.adrenalin) - 0.5;
    self.currentLevelView.lightScale = (1.0 - self.player.adrenalin);
    
    self.currentLevelView.pulse = self.player.adrenalin;
}

- (void)gameStop
{
    [self.gameTimer invalidate];
    [self.staticTimer invalidate];
    
    self.player.adrenalinHandler = nil;
    self.currentLevelView.pulse = 10.0;
    
    [self.ambientMusicController stop];
}

- (void)gameDidEnd
{
    [self gameStop];
    
    [[BDSound getInstance] playSound:SOUND_GAME_OVER];
    
    [self.gameOverViewController.view removeFromSuperview];
    self.gameOverViewController = [[BDGameOverViewController alloc] initWithNibName:nil bundle:nil];
    self.gameOverViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.gameOverViewController.view];
}

- (void)gameWin
{
    [self gameStop];
    
    [self.gameWinViewController.view removeFromSuperview];
    self.gameWinViewController = [[BDGameWinViewController alloc] initWithNibName:nil bundle:nil];
    self.gameWinViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.gameWinViewController.view];
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                         0,
                                                         [UIScreen mainScreen].applicationFrame.size.width,
                                                         [UIScreen mainScreen].applicationFrame.size.height)];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
