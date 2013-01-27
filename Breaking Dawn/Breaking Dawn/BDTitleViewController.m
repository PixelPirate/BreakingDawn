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

@property (strong, readwrite, nonatomic) UILabel *titleText;

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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.postEffectsController = [[BDPostProcessingViewController alloc] initWithNibName:nil bundle:nil];
    self.postEffectsController.view.frame = self.view.bounds;
    [self.view addSubview:self.postEffectsController.view];
    
    
    self.logoView.alpha = 0.0;
    [UIView animateWithDuration:0.5 animations:^{
        self.logoView.alpha = 1.0;
    }];
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                         0,
                                                         [UIScreen mainScreen].bounds.size.width,
                                                         [UIScreen mainScreen].bounds.size.height)];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    
    self.titleText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
    self.titleText.text = @"Nykto";
    self.titleText.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]*2.5];
    CGSize textSize = [self.titleText.text sizeWithFont:self.titleText.font
                                               forWidth:self.titleText.bounds.size.width
                                          lineBreakMode:NSLineBreakByClipping];
    self.titleText.frame = CGRectMake(0, 0, textSize.width, textSize.height);
    self.titleText.center = CGPointMake(self.view.bounds.size.width / 2.0, self.titleText.bounds.size.height/2.0);
    self.titleText.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.titleText];
    
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIEdgeInsets insets = UIEdgeInsetsMake(5.0, 0.0, 0.0, 0.0);
    self.button.frame = CGRectMake(0 + insets.left,
                                   self.titleText.frame.origin.y + self.titleText.bounds.size.height + insets.top,
                                   self.view.bounds.size.width + insets.right,
                                   70 + insets.bottom);
    self.button.contentMode = UIViewContentModeCenter;
    [self.button setImage:[UIImage imageNamed:@"start-crying-normal"] forState:UIControlStateNormal];
    [self.button setImage:[UIImage imageNamed:@"start-crying-active"] forState:UIControlStateHighlighted];
    [self.button addTarget:self action:@selector(startGame) forControlEvents:UIControlEventTouchUpInside];
    self.button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.button];
    
    self.logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo00-02"]];
    self.logoView.frame = self.view.bounds;
    self.logoView.contentMode = UIViewContentModeBottom;
    self.logoView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.logoView.alpha = 0.0;
    [self.view insertSubview:self.logoView belowSubview:self.titleText];
}

- (void)startGame
{
    [self.postEffectsController.view removeFromSuperview];
    self.postEffectsController = nil;
    
    self.gameViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.gameViewController.view];
}

- (void)restartGame
{
    [self.gameViewController.view removeFromSuperview];
    self.gameViewController = [[BDGameViewController alloc] initWithNibName:nil bundle:nil];
    
    [self viewDidAppear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
