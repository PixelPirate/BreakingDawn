//
//  BDGameWinViewController.m
//  Breaking Dawn
//
//  Created by Hendrik Klindworth on 1/27/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDGameWinViewController.h"
#import "BDAppDelegate.h"
#import "BDSound.h"

@interface BDGameWinViewController ()

@property (strong, readwrite, nonatomic) UIButton *button;

@property (strong, readwrite, nonatomic) UIImageView *room;

@property (strong, readwrite, nonatomic) NSArray *roomImages;

@property (strong, readwrite, nonatomic) NSTimer *blinkTimer;

@property (strong, readwrite, nonatomic) UIImageView *creditsView;

- (void)blinkWithTimer:(NSTimer *)timer;

- (void)restartGame;

@end


@implementation BDGameWinViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.roomImages = @[[UIImage imageNamed:@"map00-bed-bright-eyes-open00"], [UIImage imageNamed:@"map00-bed-bright-eyes-closed00"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.room.alpha = 0.0;
    self.creditsView.alpha = 0.0;
    self.creditsView.frame = CGRectMake(0,
                                        self.view.bounds.size.height,
                                        self.creditsView.frame.size.width,
                                        self.creditsView.frame.size.height);
    
    self.room.frame = CGRectMake(0, 0, self.room.image.size.width, self.room.image.size.height);
    CGFloat vscale = self.view.bounds.size.height / self.room.image.size.height;
    CGRect frame = CGRectMake(0, 0, self.room.image.size.width * vscale, self.room.image.size.height * vscale);
    CGFloat hscale = self.view.bounds.size.width / frame.size.width;
    if (hscale > 1.0) {
        frame = CGRectApplyAffineTransform(frame, CGAffineTransformMakeScale(hscale, hscale));
    }
    self.room.frame = frame;
    
    self.view.alpha = 0.0;
}

- (void)viewDidAppear:(BOOL)animated
{
    // Fade to white
    [UIView animateWithDuration:2.0 animations:^{
        self.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        // Fade to bright childrens room
        [UIView animateWithDuration:2.0 delay:3.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.room.alpha = 1.0;
        } completion:^(BOOL finished) {
            [[BDSound sharedSound] playCredits];
            self.blinkTimer = [NSTimer scheduledTimerWithTimeInterval:2.1
                                                               target:self
                                                             selector:@selector(blinkWithTimer:)
                                                             userInfo:nil
                                                              repeats:YES];
            // Scroll credits
            [UIView animateWithDuration:15.0 animations:^{
                self.creditsView.alpha = 1.0;
            }];
            [UIView animateWithDuration:30.0 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.creditsView.frame = CGRectMake(0,
                                                    - self.creditsView.bounds.size.height,
                                                    self.creditsView.frame.size.width,
                                                    self.creditsView.frame.size.height);
            } completion:^(BOOL finished) {
                int64_t delayInSeconds = 2;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    // Go to title screen
                    [self restartGame];
                });
            }];
        }];
    }];
}

- (void)blinkWithTimer:(NSTimer *)timer
{
    //Randomly blink once or twice
    switch (arc4random_uniform(2)) {
        case 0: {
            // Blink once
            self.room.image = self.roomImages[1];
            int64_t delayInMilliseconds = 200;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInMilliseconds * NSEC_PER_MSEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.room.image = self.roomImages[0];
            });
            break;
        }
        case 1: {
            // Blink twice
            self.room.image = self.roomImages[1];
            int64_t delayInMilliseconds = 200;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInMilliseconds * NSEC_PER_MSEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.room.image = self.roomImages[0];
                int64_t delayInMilliseconds = 250;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInMilliseconds * NSEC_PER_MSEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    self.room.image = self.roomImages[1];
                    int64_t delayInMilliseconds = 200;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInMilliseconds * NSEC_PER_MSEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        self.room.image = self.roomImages[0];
                    });
                });
            });
            break;
        }
        default:
            break;
    }
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                         0,
                                                         [UIScreen mainScreen].applicationFrame.size.width,
                                                         [UIScreen mainScreen].applicationFrame.size.height)];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
    
    self.room = [[UIImageView alloc] initWithImage:self.roomImages.lastObject];
    self.room.frame = self.view.bounds;
    self.room.contentMode = UIViewContentModeScaleAspectFill;
    self.room.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.room];
    
    self.creditsView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"credits-scroll00"]];
    self.creditsView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height * 3.0);
    self.creditsView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.creditsView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.creditsView];
}

- (void)restartGame
{
    [[BDSound sharedSound] stopCredits];
    [self.blinkTimer invalidate];
    BDAppDelegate *d = [[UIApplication sharedApplication] delegate];
    [d.titleViewController restartGame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
