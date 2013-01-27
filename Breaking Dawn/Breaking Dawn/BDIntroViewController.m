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

- (void)gotoTitleView
{
    self.titleViewController.view.alpha = 0.0;
    self.titleViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.titleViewController.view];
    [UIView animateWithDuration:0.5 animations:^{
        self.titleViewController.view.alpha = 1.0;
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if([[NSUserDefaults standardUserDefaults] floatForKey:@"SkipIntro"]) {
        [self gotoTitleView];
        return;
    }
    
    UIImageView *dummy = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GGJ13_RoundBadge"]];
    dummy.frame = self.view.bounds;
    dummy.contentMode = UIViewContentModeScaleAspectFit;
    dummy.backgroundColor = [UIColor blackColor];
    dummy.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:dummy];
    self.view.backgroundColor = [UIColor blackColor];
    
    
    UIImageView *sleepingGirlView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro-girl-01.jpg"]];
    sleepingGirlView.frame = self.view.bounds;
    sleepingGirlView.contentMode = UIViewContentModeScaleAspectFill;
    sleepingGirlView.backgroundColor = [UIColor clearColor];
    sleepingGirlView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    UIImageView *wakeGirlView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro-girl-02.jpg"]];
    wakeGirlView.frame = self.view.bounds;
    wakeGirlView.contentMode = UIViewContentModeScaleAspectFill;
    wakeGirlView.backgroundColor = [UIColor clearColor];
    wakeGirlView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    UIImageView *brightDoorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro-door-01.jpg"]];
    brightDoorView.frame = self.view.bounds;
    brightDoorView.contentMode = UIViewContentModeScaleAspectFill;
    brightDoorView.backgroundColor = [UIColor clearColor];
    brightDoorView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    UIImageView *dimmDoorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro-door-02.jpg"]];
    dimmDoorView.frame = self.view.bounds;
    dimmDoorView.contentMode = UIViewContentModeScaleAspectFill;
    dimmDoorView.backgroundColor = [UIColor clearColor];
    dimmDoorView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    UIImageView *darkDoorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro-door-03.jpg"]];
    darkDoorView.frame = self.view.bounds;
    darkDoorView.contentMode = UIViewContentModeScaleAspectFill;
    darkDoorView.backgroundColor = [UIColor clearColor];
    darkDoorView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    int64_t delayInSeconds = 4.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self.view insertSubview:sleepingGirlView belowSubview:dummy];
        
        [UIView animateWithDuration:0.5 animations:^{
            dummy.alpha = 0.0;
        } completion:^(BOOL finished) {
            
            int64_t delayInSeconds = 1.5; // show sleeping girl
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self.view addSubview:brightDoorView];
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
                                                            [self gotoTitleView];
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
            });
        }];
    });
};

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.view.alpha = 0.0;
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 1.0;
    }];
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                         0,
                                                         [UIScreen mainScreen].bounds.size.width,
                                                         [UIScreen mainScreen].bounds.size.height)];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
