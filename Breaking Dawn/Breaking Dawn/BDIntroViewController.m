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
        
        BDAppDelegate *d = [[UIApplication sharedApplication] delegate];
        d.titleViewController = self.titleViewController;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel *dummy = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 350, 100)];
    dummy.center = CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0);
    dummy.text = @"B̶r̶e̶a̶k̶i̶n̶g̶ ̶D̶a̶w̶n̶ Nykto";
    dummy.textAlignment = NSTextAlignmentCenter;
    dummy.backgroundColor = [UIColor blackColor];
    dummy.textColor = [UIColor whiteColor];
    dummy.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]*2.0];
    dummy.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [self.view addSubview:dummy];
    
    
    int64_t delayInSeconds = 4.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:0.5 animations:^{
            self.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.titleViewController.view.alpha = 0.0;
            [self presentViewController:self.titleViewController animated:NO completion:^{
                [UIView animateWithDuration:0.5 animations:^{
                    self.titleViewController.view.alpha = 1.0;
                }];
            }];
            [dummy removeFromSuperview];
        }];
    });
    
    
    self.view.alpha = 0.0;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 1.0;
    }];
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                         0,
                                                         [UIScreen mainScreen].applicationFrame.size.width,
                                                         [UIScreen mainScreen].applicationFrame.size.height)];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
