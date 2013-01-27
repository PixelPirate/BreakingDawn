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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *dummy = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GGJ13_RoundBadge"]];
    dummy.frame = self.view.bounds;
    dummy.contentMode = UIViewContentModeScaleAspectFit;
    dummy.backgroundColor = [UIColor clearColor];
    dummy.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:dummy];
    self.view.backgroundColor = [UIColor blackColor];
    
    // Change this to skip intro
    int64_t delayInSeconds = 4.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [UIView animateWithDuration:0.5 animations:^{
            dummy.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.titleViewController.view.alpha = 0.0;
            self.titleViewController.view.frame = self.view.bounds;
            [self.view addSubview:self.titleViewController.view];
            [UIView animateWithDuration:0.5 animations:^{
                self.titleViewController.view.alpha = 1.0;
            }];
        }];
    });
}

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
