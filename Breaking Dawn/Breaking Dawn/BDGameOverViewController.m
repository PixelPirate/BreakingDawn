//
//  BDGameOverViewController.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDGameOverViewController.h"
#import "BDAppDelegate.h"
#import "BDPostProcessingViewController.h"

@interface BDGameOverViewController ()

@property (strong, readwrite, nonatomic) UIButton *button;

@property (strong, readwrite, nonatomic) BDPostProcessingViewController *postProcessingViewController;

- (void)restartGame;

@end

@implementation BDGameOverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.postProcessingViewController = [[BDPostProcessingViewController alloc] initWithNibName:nil bundle:nil];
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
    
    self.postProcessingViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.postProcessingViewController.view];
    
    UILabel *dummy = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    dummy.text = [NSString stringWithFormat:@"Game Over, %@", @[@"Bitch", @"Dirtbag", @"Fool", @"Foolish Mortal"][arc4random_uniform(4)]];
    dummy.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    CGSize textSize = [dummy.text sizeWithFont:dummy.font
                                      forWidth:dummy.bounds.size.width
                                 lineBreakMode:NSLineBreakByClipping];
    dummy.frame = CGRectMake(0, 0, textSize.width, textSize.height);
    dummy.center = CGPointMake(self.view.bounds.size.width / 2.0, 20);
    dummy.textAlignment = NSTextAlignmentCenter;
    dummy.backgroundColor = [UIColor blackColor];
    dummy.textColor = [UIColor whiteColor];
    dummy.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:dummy];
    
    UIImageView *title = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@[@"fail-01", @"fail-02", @"fail-03", @"fail-04"][arc4random_uniform(4)]]];
    title.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, title.image.size.height);
    title.center = CGPointMake(self.view.bounds.size.width / 2.0, (self.view.bounds.size.height / 2.0) - 70.0);
    title.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    title.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:title];
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = CGRectMake(0, title.frame.origin.y + title.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - (title.frame.origin.y + title.frame.size.height));
    self.button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    self.button.contentMode = UIViewContentModeScaleAspectFit;
    [self.button setImage:[UIImage imageNamed:@"cry-again-normal"] forState:UIControlStateNormal];
    [self.button setImage:[UIImage imageNamed:@"cry-again-active"] forState:UIControlStateHighlighted];
    [self.button addTarget:self action:@selector(restartGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
}

- (void)restartGame
{
    BDAppDelegate *d = [[UIApplication sharedApplication] delegate];
    [d.titleViewController restartGame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
