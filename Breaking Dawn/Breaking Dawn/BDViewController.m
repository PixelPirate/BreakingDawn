//
//  BDViewController.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/25/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDViewController.h"
#import "BDIntroViewController.h"

@interface BDViewController () // Private setter

//@property (strong, readwrite, nonatomic) BDGameViewController *gameViewController;
@property (strong, readwrite, nonatomic) BDIntroViewController *introViewController;
@property (strong, readwrite, nonatomic) UISlider *light;
@property (strong, readwrite, nonatomic) UISlider *dusk;
@property (strong, readwrite, nonatomic) UISlider *dark;
@property (strong, readwrite, nonatomic) UILabel *ll;
@property (strong, readwrite, nonatomic) UILabel *dl;
@property (strong, readwrite, nonatomic) UILabel *ddl;
@end

@implementation BDViewController

- (void)lightC
{
    [[NSUserDefaults standardUserDefaults] setFloat:self.light.value forKey:@"AdrenalinLight"];
    self.ll.text = [NSString stringWithFormat:@"%f", self.light.value];
}

- (void)duskC
{
    [[NSUserDefaults standardUserDefaults] setFloat:self.dusk.value forKey:@"AdrenalinDusk"];
    self.dl.text = [NSString stringWithFormat:@"%f", self.dusk.value];
}

- (void)darkC
{
    [[NSUserDefaults standardUserDefaults] setFloat:self.dark.value forKey:@"AdrenalinDark"];
    self.ddl.text = [NSString stringWithFormat:@"%f", self.dark.value];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //self.gameViewController = [[BDGameViewController alloc] initWithNibName:nil bundle:nil];
    self.introViewController = [[BDIntroViewController alloc] initWithNibName:nil bundle:nil];
    
    [self.view addSubview:self.introViewController.view];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [[NSUserDefaults standardUserDefaults] setFloat:0.024 forKey:@"AdrenalinLight"];
    [[NSUserDefaults standardUserDefaults] setFloat:0.0068 forKey:@"AdrenalinDusk"];
    [[NSUserDefaults standardUserDefaults] setFloat:0.012 forKey:@"AdrenalinDark"];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DebugMenu"]) {
        self.light = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, 20)];
        self.light.value = 0.006;
        self.light.maximumValue = 0.1;
        [self.light addTarget:self action:@selector(lightC) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:self.light];
        self.light.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
        self.ll = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].applicationFrame.size.width, 20)];
        self.ll.text = [NSString stringWithFormat:@"%f", self.light.value];
        [self.view addSubview:self.ll];
        self.ll.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
        
        self.dusk = [[UISlider alloc] initWithFrame:CGRectMake(0, 40, [UIScreen mainScreen].applicationFrame.size.width, 20)];
        self.dusk.value = 0.002;
        self.dusk.maximumValue = 0.1;
        [self.dusk addTarget:self action:@selector(duskC) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:self.dusk];
        self.dusk.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
        self.dl = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, [UIScreen mainScreen].applicationFrame.size.width, 20)];
        self.dl.text = [NSString stringWithFormat:@"%f", self.dusk.value];
        [self.view addSubview:self.dl];
        self.dl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
        
        self.dark = [[UISlider alloc] initWithFrame:CGRectMake(0, 80, [UIScreen mainScreen].applicationFrame.size.width, 20)];
        self.dark.value = 0.006;
        self.dark.maximumValue = 0.1;
        [self.dark addTarget:self action:@selector(darkC) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:self.dark];
        self.dark.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
        self.ddl = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].applicationFrame.size.width, 20)];
        self.ddl.text = [NSString stringWithFormat:@"%f", self.dark.value];
        [self.view addSubview:self.ddl];
        self.ddl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
