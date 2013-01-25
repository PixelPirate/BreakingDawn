//
//  BDViewController.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/25/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDViewController.h"
#import "BDGameViewController.h"

@interface BDViewController () // Private setter

@property (strong, readwrite, nonatomic) BDGameViewController *gameViewController;

@end

@implementation BDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.gameViewController = [[BDGameViewController alloc] initWithNibName:nil bundle:nil];
    
    [self.view addSubview:self.gameViewController.view];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
