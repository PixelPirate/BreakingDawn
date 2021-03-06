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
#import "BDLightView.h"


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

@property (assign, readwrite, nonatomic) BOOL gameInProgress;

- (void)tickWithTimer:(NSTimer *)timer;

- (void)adrenalinChanged;

- (void)gameDidEnd;

- (void)transitionToLevel:(BDLevel *)level animated:(BOOL)animated;

- (void)addPostProcessingEffects;

- (void)startGame;

@end


@implementation BDGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.lastTouchLocation = CGPointZero;
        self.gameInProgress = NO;
        self.ambientMusicController = [BDAmbientMusicController sharedAmbientMusicController];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*
    self.currentLevel = [[BDLevel alloc] initWithLevelNamed:@"Map00.json"];
    self.currentLevel.delegate = self;
    self.currentLevelView = [[BDLevelView alloc] initWithLevel:self.currentLevel];
    
    self.player = [[BDPlayer alloc] initWithPosition:self.currentLevel.spawn];
    self.playerView = [[BDPlayerView alloc] initWithPlayer:self.player];
    __weak id s = self;
    self.player.adrenalinHandler = ^{
        [s adrenalinChanged];
    };
    */
    
    [self transitionToLevel:[[BDLevel alloc] initWithLevelNamed:@"Map00.json"] animated:NO];
    
    self.sound = [BDSound sharedSound];
    
//    [self.currentLevelView.playerLayer addSubview:self.playerView];
//    [self.view addSubview:self.currentLevelView];
    
    self.lastTouchLocation = CGPointZero;
    
    self.view.alpha = 0.0;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"RealisticLighting"]) {
        BDLightView *light = [[BDLightView alloc] initWithPosition:CGPointApplyAffineTransform(self.currentLevel.spawn,
                                                                                               CGAffineTransformMakeTranslation(-10, -10))
                                                           inLevel:self.currentLevel];
        [self.currentLevelView addSubview:light];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self addPostProcessingEffects];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startGame];
    
    int64_t delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:0.5 animations:^{
            self.view.alpha = 1.0;
        }];
    });
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.postProcessingViewController.view removeFromSuperview];
    self.postProcessingViewController.flickerView = nil;
    self.postProcessingViewController = nil;
    
    [self.playerView removeFromSuperview];
    self.playerView = nil;
    [self.currentLevelView removeFromSuperview];
    self.currentLevelView = nil;
}

- (void)addPostProcessingEffects
{
    [self.postProcessingViewController.view removeFromSuperview];
    self.postProcessingViewController = [[BDPostProcessingViewController alloc] initWithNibName:nil bundle:nil];
    self.postProcessingViewController.flickerView = self.currentLevelView.surfaceLayer;
    self.postProcessingViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.postProcessingViewController.view];
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
        // Try to move at least in one the directions
        CGPoint pushBack[3] = { CGPointMake(-1, -1), CGPointMake(0, -1), CGPointMake(-1, 0), };
        for (NSUInteger i = 0; i < 3; i++) {
            CGPoint newLocation = CGPointApplyAffineTransform(self.player.location,
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
    
    // Evaluate trap and timed lights.
    [self.currentLevel evaluateLightsForPlayerAtPosition:self.player.location];
    
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
                [[BDSound sharedSound] playMonster:arc4random_uniform(5)];
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
    self.currentLevel.lightScale = (1.0 - self.player.adrenalin);
    [self.currentLevelView reloadData];
    self.currentLevelView.pulse = self.player.adrenalin;
}

- (void)transitionToLevel:(BDLevel *)level animated:(BOOL)animated
{
    [self gameStop];
    
    __weak BDGameViewController *__self = self;
    void(^fadeOutBlock)(void) = ^(void) {
        __self.currentLevelView.alpha = 0.0;
    };
    
    void(^completitionBlock)(BOOL finished) = ^(BOOL finished) {
        [__self.currentLevelView removeFromSuperview];
        __self.currentLevelView = nil;
        [__self.playerView removeFromSuperview];
        __self.playerView = nil;
        
        __self.currentLevel = nil;
        __self.player = nil;
        
        __self.currentLevel = level;
        __self.currentLevel.delegate = __self;
        __self.currentLevelView = [[BDLevelView alloc] initWithLevel:__self.currentLevel];
        __self.player = [[BDPlayer alloc] initWithPosition:__self.currentLevel.spawn];
        __weak id s = __self;
        __self.player.adrenalinHandler = ^{
            [s adrenalinChanged];
        };
        __self.playerView = [[BDPlayerView alloc] initWithPlayer:__self.player];
        
        [__self.currentLevelView.playerLayer addSubview:__self.playerView];
        __self.currentLevelView.alpha = 0.0;
        [__self.view addSubview:__self.currentLevelView];
        
        [__self addPostProcessingEffects];
        [UIView animateWithDuration:0.5 animations:^{
            __self.currentLevelView.alpha = 1.0;
        }];
        [self startGame];
    };
    
    self.view.backgroundColor = [UIColor blackColor];
    
    if (animated) {
        [UIView animateWithDuration:0.5 animations:fadeOutBlock completion:completitionBlock];
    } else {
        completitionBlock(YES);
    }
}

- (void)startGame
{
    if (self.gameInProgress) return;
    
    [self.currentLevel levelDidBegin];
    
    [self.staticTimer invalidate];
    self.staticTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                        target:self.postProcessingViewController
                                                      selector:@selector(static)
                                                      userInfo:nil
                                                       repeats:YES];
    [self.gameTimer invalidate];
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:[[NSUserDefaults standardUserDefaults] floatForKey:@"DrawRate"]
                                                      target:self
                                                    selector:@selector(tickWithTimer:)
                                                    userInfo:nil
                                                     repeats:YES];
    [self.ambientMusicController play];
    [self.sound beginHeartbeatForPlayer:self.player];
    
    self.gameInProgress = YES;
}

- (void)gameStop
{
    if (!self.gameInProgress) return;
    
    [self.gameTimer invalidate];
    [self.staticTimer invalidate];
    
    self.player.adrenalinHandler = nil;
    self.currentLevelView.pulse = 10.0;
    
    [self.ambientMusicController stop];
    [self.sound endHeartbeat];

    // Cannot nil the level views, they are still used for the transition to the game over screen.
    self.currentLevel = nil;
    self.player = nil;
    
    self.gameInProgress = NO;
}

- (void)gameDidEnd
{
    [self gameStop];
    
    [[BDSound sharedSound] playSound:SOUND_GAME_OVER];
    
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

#pragma mark - BDLevelDelegate implementation

- (void)level:(BDLevel *)level didAddLights:(NSArray *)lights
{
    [self.currentLevelView reloadData];
}

- (void)level:(BDLevel *)level didChangeState:(NSString *)state toState:(NSString *)newState
{
    [self.currentLevelView reloadData];
}

- (void)level:(BDLevel *)level didChangePlayerPosition:(CGPoint)position
{
    self.player.location = position;
}

- (void)level:(BDLevel *)level shouldChangeToLevel:(BDLevel *)newLevel
{
    [self transitionToLevel:newLevel animated:YES];
}

- (void)levelWillWin:(BDLevel *)level
{
    [self gameWin];
}

- (void)levelDidFail:(BDLevel *)level
{
    [self gameDidEnd];
}

@end
