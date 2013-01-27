//
//  BDGameWinViewController.m
//  Breaking Dawn
//
//  Created by Hendrik Klindworth on 1/27/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDGameWinViewController.h"
#import "BDAppDelegate.h"

@interface BDGameWinViewController ()

@property (strong, readwrite, nonatomic) UIButton *button;

@end

@implementation BDGameWinViewController

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
    
    UILabel *dummy = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    dummy.text = [NSString stringWithFormat:@"Winner, %@", @[@"Bitch", @"Dirtbag", @"Fool", @"Foolish Mortal"][arc4random_uniform(3)]];
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
    title.frame = CGRectMake(0.0, 0.0, title.image.size.width, title.image.size.height);
    title.center = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0);
    title.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:title];
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = CGRectMake(0, 0, 390, 60);
    self.button.center = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 1.5);
    self.button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    //[self.button setTitle:@"Title Screen" forState:UIControlStateNormal];
    self.button.contentMode = UIViewContentModeTop;
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
    // Dispose of any resources that can be recreated.
}

@end
