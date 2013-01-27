//
//  BDGameOverViewController.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDGameOverViewController.h"

@interface BDGameOverViewController ()

@property (strong, readwrite, nonatomic) UIButton *button;

- (void)restartGame;

@end

@implementation BDGameOverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                         0,
                                                         [UIScreen mainScreen].applicationFrame.size.width,
                                                         [UIScreen mainScreen].applicationFrame.size.height)];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
    
    UILabel *dummy = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 20)];
    dummy.center = CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0);
    dummy.text = [NSString stringWithFormat:@"Game Over, %@", @[@"Bitch", @"Dirtbag", @"Fool"][arc4random_uniform(3)]];
    dummy.textAlignment = NSTextAlignmentCenter;
    dummy.backgroundColor = [UIColor blackColor];
    dummy.textColor = [UIColor whiteColor];
    dummy.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    dummy.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:dummy];
    
    self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.button.frame = CGRectMake(0, 0, 100, 20);
    self.button.center = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 1.5);
    self.button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.button setTitle:@"Title Screen" forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(restartGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
}

- (void)restartGame
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
