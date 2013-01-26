//
//  BDPostProcessingViewController.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDPostProcessingViewController.h"

@interface BDPostProcessingViewController ()

@property (strong, nonatomic) UIImageView *noiseImageView;

@property (strong, nonatomic) CIContext *noiseContext;

@property (strong, nonatomic) CIImage *noiseImage;

@end

@implementation BDPostProcessingViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView
{
    UIView *postProcessingView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          [UIScreen mainScreen].applicationFrame.size.width,
                                                                          [UIScreen mainScreen].applicationFrame.size.height)];
    
    postProcessingView.backgroundColor = [UIColor clearColor];
    
    self.view = postProcessingView;
    
    self.noiseContext = [CIContext contextWithOptions:nil];
    
    CIFilter *noiseGenerator = [CIFilter filterWithName:@"CIColorMonochrome"];
    [noiseGenerator setValue:[[CIFilter filterWithName:@"CIRandomGenerator"] valueForKey:@"outputImage"] forKey:@"inputImage"];
    [noiseGenerator setDefaults];
    
    self.noiseImage = [noiseGenerator outputImage];
    
    CGSize extentSize = CGSizeMake(5, 5);
    CGRect extentRect = [self.noiseImage extent];
    if (CGRectIsInfinite(extentRect) || CGRectIsEmpty(extentRect)) {
        extentRect = CGRectMake(100, 30, extentSize.width, extentSize.height);
    }
    
    CGImageRef __noiseImage = [self.noiseContext createCGImage:self.noiseImage fromRect:extentRect];
    self.noiseImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:__noiseImage]];
    CGImageRelease(__noiseImage);
    self.noiseImageView.frame = self.view.bounds;
    self.noiseImageView.alpha = arc4random_uniform(300) / 6000.0 + 0.1;
    [self.view addSubview:self.noiseImageView];
    self.view.userInteractionEnabled = NO;
    self.noiseImageView.userInteractionEnabled = NO;
    
    __block void(^rand)(void) = ^(void) {
        CGRect extentRect = [self.noiseImage extent];
        if (CGRectIsInfinite(extentRect) || CGRectIsEmpty(extentRect)) {
            extentRect = CGRectMake(arc4random_uniform(100), arc4random_uniform(100), extentSize.width, extentSize.height);
        }
        
        CGImageRef __noiseImage = [self.noiseContext createCGImage:self.noiseImage fromRect:extentRect];
        
        UIImageView *i = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:__noiseImage]];
        i.userInteractionEnabled = NO;
        i.alpha = arc4random_uniform(300) / 6000.0 + 0.1;
        CGImageRelease(__noiseImage);
        i.frame = self.noiseImageView.frame;
        [UIView transitionFromView:self.noiseImageView
                            toView:i
                          duration:1.9
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        completion:^(BOOL finished) {
            self.noiseImageView = i;
        }];
        
        int64_t delayInMilliseconds = 1000;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInMilliseconds * NSEC_PER_MSEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            rand();
        });
    };
    
    rand();
}

@end
