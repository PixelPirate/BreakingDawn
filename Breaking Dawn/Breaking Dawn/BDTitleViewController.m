//
//  BDTitleViewController.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDTitleViewController.h"
#import "BDGameViewController.h"
#import "BDPostProcessingViewController.h"

@interface BDTitleViewController ()

@property (strong, readwrite, nonatomic) BDGameViewController *gameViewController;

@property (strong, readwrite, nonatomic) BDPostProcessingViewController *postEffectsController;

@property (strong, readwrite, nonatomic) UIImageView *logoView;

@property (strong, readwrite, nonatomic) UIButton *button;

- (void)startGame;

@end

@implementation BDTitleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.gameViewController = [[BDGameViewController alloc] initWithNibName:nil bundle:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.button.frame = CGRectMake(0, 0, 100, 20);
    self.button.center = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 4.0);
    [self.button setTitle:@"Start Game" forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(startGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    self.button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.postEffectsController = [[BDPostProcessingViewController alloc] initWithNibName:nil bundle:nil];
    self.postEffectsController.view.frame = self.view.bounds;
    [self.view addSubview:self.postEffectsController.view];
    
    self.logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo00-02"]];
    
    self.logoView.frame = self.view.bounds;
    self.logoView.contentMode = UIViewContentModeBottom;
    [self.view insertSubview:self.logoView belowSubview:self.button];
    self.logoView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    
    self.logoView.alpha = 0.0;
    [UIView animateWithDuration:0.5 animations:^{
        self.logoView.alpha = 1.0;
    }];
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                         0,
                                                         [UIScreen mainScreen].applicationFrame.size.width,
                                                         [UIScreen mainScreen].applicationFrame.size.height)];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
}

- (void)startGame
{
    NSLog(@"%@", self.view);
    self.view.userInteractionEnabled = NO;
    [self presentViewController:self.gameViewController animated:NO completion:^{
        NSLog(@"%@", self.gameViewController.view);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
