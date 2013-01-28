//
//  BDIntroViewController.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDIntroViewController.h"
#import "BDTitleViewController.h"
#import "BDAppDelegate.h"

@interface BDIntroViewController ()

@property (strong, readwrite, nonatomic) BDTitleViewController *titleViewController;

@property (strong, readwrite, nonatomic) UIView *coverView;

@property (strong, readwrite, nonatomic) UIView *wakeGirlView;

@property (strong, readwrite, nonatomic) UIView *sleepingGirlView;

@property (strong, readwrite, nonatomic) UIView *darkDoorView;

@property (strong, readwrite, nonatomic) UIView *dimmDoorView;

@property (strong, readwrite, nonatomic) UIView *brightDoorView;

@property (strong, readwrite, nonatomic) UIView *doorViews;

@property (strong, readwrite, nonatomic) UIView *girlViews;

- (void)transitionToTitleScreen;

@end


@implementation BDIntroViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.titleViewController = [[BDTitleViewController alloc] initWithNibName:nil bundle:nil];
        BDAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        delegate.titleViewController = self.titleViewController;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SkipIntro"]) {
        [self transitionToTitleScreen];
    }
    
    self.girlViews.alpha = 0.0;
    self.doorViews.alpha = 0.0;
    self.view.alpha = 0.0;
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 1.0;  // Fade in Global Games Jam logo.
    } completion:^(BOOL finished) {
        // Change this to skip intro
        self.girlViews.alpha = 1.0;
        self.doorViews.alpha = 1.0;
        int64_t delayInSeconds = 4.0; // After 4 seconds...
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [UIView animateWithDuration:0.5 animations:^{
                self.coverView.alpha = 0.0;  // Fade to the sleeping girl
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:10.1 delay:2.4 options:0 animations:^{
                    self.doorViews.transform = CGAffineTransformMakeScale(1.2, 1.2);
                } completion:nil];
                [UIView animateWithDuration:1.0 delay:2.5 options:0 animations:^{
                    // Zoom in on the door, while it begins to flicker and finaly goes dark.
                    
                    self.girlViews.alpha = 0.0; // Fade from girl to door
                    
                } completion:^(BOOL finished) {
                    
                    // Show bright door.
                    [UIView animateWithDuration:0.01 delay:2.0 options:0 animations:^{
                        self.brightDoorView.alpha = 0.0; // Show dimm door
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.01 delay:0.01 options:0 animations:^{
                            self.brightDoorView.alpha = 1.0; // Show bright door
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:0.01 delay:0.01 options:0 animations:^{
                                self.brightDoorView.alpha = 0.1; // Show dimm door
                            } completion:^(BOOL finished) {
                                [UIView animateWithDuration:0.01 delay:0.01 options:0 animations:^{
                                    self.brightDoorView.alpha = 1.0; // Show bright door
                                } completion:^(BOOL finished) {
                                    [UIView animateWithDuration:0.1 delay:0.8 options:0 animations:^{
                                        self.brightDoorView.alpha = 0.5; // Show dimm door
                                    } completion:^(BOOL finished) {
                                        [UIView animateWithDuration:0.1 delay:0.1 options:0 animations:^{
                                            self.brightDoorView.alpha = 0.8; // show bright door
                                        } completion:^(BOOL finished) {
                                            [UIView animateWithDuration:0.1 delay:1.0 options:0 animations:^{
                                                self.brightDoorView.alpha = 0.1; // show dimm door
                                            } completion:^(BOOL finished) {
                                                [UIView animateWithDuration:0.1 delay:0.6 options:0 animations:^{
                                                    self.brightDoorView.alpha = 1.0; // show bright door
                                                } completion:^(BOOL finished) {
                                                    self.dimmDoorView.alpha = 0.0;
                                                    [UIView animateWithDuration:1.0 delay:1.5 options:0 animations:^{
                                                        self.brightDoorView.alpha = 0.0; // Show dark door
                                                    } completion:^(BOOL finished) {
                                                        [UIView animateWithDuration:1.0 delay:2.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                                                            self.girlViews.alpha = 1.0; // Show girl;
                                                        } completion:^(BOOL finished) {
                                                            self.girlViews.alpha = 1.0; // Show girl;
                                                            [UIView animateWithDuration:0.3 delay:2.0 options:0 animations:^{
                                                                self.sleepingGirlView.alpha = 0.0;
                                                            } completion:^(BOOL finished) {
                                                                [UIView animateWithDuration:0.01 delay:1.0 options:0 animations:^{
                                                                    self.sleepingGirlView.alpha = 1.0; // Girl blinks
                                                                } completion:^(BOOL finished) {
                                                                    [UIView animateWithDuration:0.01 delay:0.1 options:0 animations:^{
                                                                        self.sleepingGirlView.alpha = 0.0;
                                                                    } completion:^(BOOL finished) {
                                                                        [self transitionToTitleScreen];
                                                                    }];
                                                                }];
                                                            }];
                                                        }];
                                                    }];
                                                }];
                                            }];
                                        }];
                                    }];
                                }];
                            }];
                        }];
                    }];
                    // Girl waking up.
                }];
                /*
                int64_t delayInSeconds = 2.5; // Show sleeping girl
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    
                    
                    
                    int64_t delayInSeconds = 1.5; // Show bright door.
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        
                        
                        // Now flicker that shit!
                        [self.view insertSubview:dimmDoorView belowSubview:brightDoorView];
                        
                        [UIView animateWithDuration:0.01 delay:0.0 options:0 animations:^{
                            brightDoorView.alpha = 0.0;
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:0.01 delay:0.5 options:0 animations:^{
                                brightDoorView.alpha = 0.8;
                            } completion:^(BOOL finished) {
                                [UIView animateWithDuration:0.2 delay:0.4 options:0 animations:^{
                                    brightDoorView.alpha = 0.1;
                                } completion:^(BOOL finished) {
                                    [UIView animateWithDuration:0.01 delay:0.6 options:0 animations:^{
                                        brightDoorView.alpha = 1.0;
                                    } completion:^(BOOL finished) {
                                        [UIView animateWithDuration:0.02 delay:0.3 options:0 animations:^{
                                            brightDoorView.alpha = 0.2;
                                        } completion:^(BOOL finished) {
                                            [UIView animateWithDuration:0.01 delay:0.2 options:0 animations:^{
                                                brightDoorView.alpha = 1.0;
                                            } completion:^(BOOL finished) {
                                                [self.view insertSubview:darkDoorView belowSubview:dimmDoorView];
                                                dimmDoorView.alpha = 0.0;
                                                [UIView animateWithDuration:0.01 delay:0.2 options:0 animations:^{
                                                    brightDoorView.alpha = 0.0;
                                                } completion:^(BOOL finished) {
                                                    [UIView animateWithDuration:0.01 delay:2.5 options:0 animations:^{
                                                        darkDoorView.alpha = 0.0;
                                                    } completion:^(BOOL finished) {
                                                        [self.view insertSubview:wakeGirlView belowSubview:sleepingGirlView];
                                                        [UIView animateWithDuration:0.01 delay:2.5 options:0 animations:^{
                                                            sleepingGirlView.alpha = 0.0;
                                                        } completion:^(BOOL finished) {
                                                            int64_t delayInSeconds = 1.0;
                                                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                                self.titleViewController.view.alpha = 0.0;
                                                                self.titleViewController.view.frame = self.view.bounds;
                                                                [self.view addSubview:self.titleViewController.view];
                                                                [UIView animateWithDuration:0.5 animations:^{
                                                                    self.titleViewController.view.alpha = 1.0;
                                                                }];
                                                            });
                                                            
                                                        }];
                                                    }];
                                                }];
                                            }];
                                        }];
                                    }];
                                }];
                            }];
                        }];
                        
                    });
                });*/
            }];
        });
    }];
}

- (void)transitionToTitleScreen
{
    self.titleViewController.view.alpha = 0.0;
    self.titleViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.titleViewController.view];
    [UIView animateWithDuration:0.5 animations:^{
        self.titleViewController.view.alpha = 1.0;
    }];
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                         0,
                                                         [UIScreen mainScreen].bounds.size.width,
                                                         [UIScreen mainScreen].bounds.size.height)];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    
    self.coverView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GGJ13_RoundBadge"]];
    self.coverView.frame = self.view.bounds;
    self.coverView.contentMode = UIViewContentModeScaleAspectFit;
    self.coverView.backgroundColor = [UIColor blackColor];
    self.coverView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.coverView];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.girlViews = [[UIView alloc] initWithFrame:self.view.bounds];
    self.girlViews.backgroundColor = [UIColor blackColor];
    self.girlViews.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.sleepingGirlView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro-girl-01.jpg"]];
    self.sleepingGirlView.frame = self.girlViews.bounds;
    self.sleepingGirlView.contentMode = UIViewContentModeScaleAspectFill;
    self.sleepingGirlView.backgroundColor = [UIColor clearColor];
    self.sleepingGirlView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.wakeGirlView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro-girl-02.jpg"]];
    self.wakeGirlView.frame = self.girlViews.bounds;
    self.wakeGirlView.contentMode = UIViewContentModeScaleAspectFill;
    self.wakeGirlView.backgroundColor = [UIColor clearColor];
    self.wakeGirlView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.girlViews addSubview:self.wakeGirlView];
    [self.girlViews addSubview:self.sleepingGirlView];
    
    [self.view insertSubview:self.girlViews belowSubview:self.coverView];
    
    self.doorViews = [[UIView alloc] initWithFrame:self.view.bounds];
    self.doorViews.backgroundColor = [UIColor blackColor];
    self.doorViews.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.brightDoorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro-door-01.jpg"]];
    self.brightDoorView.frame = self.doorViews.bounds;
    self.brightDoorView.contentMode = UIViewContentModeScaleAspectFill;
    self.brightDoorView.backgroundColor = [UIColor clearColor];
    self.brightDoorView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.dimmDoorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro-door-02.jpg"]];
    self.dimmDoorView.frame = self.doorViews.bounds;
    self.dimmDoorView.contentMode = UIViewContentModeScaleAspectFill;
    self.dimmDoorView.backgroundColor = [UIColor clearColor];
    self.dimmDoorView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.darkDoorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro-door-03.jpg"]];
    self.darkDoorView.frame = self.doorViews.bounds;
    self.darkDoorView.contentMode = UIViewContentModeScaleAspectFill;
    self.darkDoorView.backgroundColor = [UIColor clearColor];
    self.darkDoorView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.doorViews addSubview:self.darkDoorView];
    [self.doorViews addSubview:self.dimmDoorView];
    [self.doorViews addSubview:self.brightDoorView];
    
    [self.view insertSubview:self.doorViews belowSubview:self.girlViews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
