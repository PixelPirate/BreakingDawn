//
//  BDPostProcessingViewController.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDPostProcessingViewController.h"
#import "BDLevelView.h"

@interface BDPostProcessingViewController ()

@property (strong, nonatomic) UIImageView *noiseImageView;

@property (strong, readwrite, nonatomic) NSTimer *noiseTimer;

- (void)changeNoise;

+ (NSArray *)noiseTextures;

@end

@implementation BDPostProcessingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.userInteractionEnabled = NO;
    }
    return self;
}

+ (NSArray *)noiseTextures
{
    static NSMutableArray *_noiseTextures = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            _noiseTextures = [NSMutableArray array];
            CIContext *noiseContext = [CIContext contextWithOptions:nil];
            
            CIFilter *noiseGenerator = [CIFilter filterWithName:@"CIColorMonochrome"];
            [noiseGenerator setValue:[[CIFilter filterWithName:@"CIRandomGenerator"] valueForKey:@"outputImage"] forKey:@"inputImage"];
            [noiseGenerator setDefaults];
            
            CIImage *noiseImage = [noiseGenerator outputImage];
            
            CGSize extentSize = CGSizeMake(480, 480);
            
            for (NSUInteger i = 0; i < 5; ++i) {
                CGRect extentRect = [noiseImage extent];
                if (CGRectIsInfinite(extentRect) || CGRectIsEmpty(extentRect)) {
                    extentRect = CGRectMake(arc4random_uniform(100), arc4random_uniform(100), extentSize.width, extentSize.height);
                }
                
                CGImageRef __noiseImage = [noiseContext createCGImage:noiseImage fromRect:extentRect];
                [_noiseTextures addObject:[UIImage imageWithCGImage:__noiseImage]];
                CGImageRelease(__noiseImage);
            }
        }
    });
    return _noiseTextures;
}

- (void)loadView
{
    UIView *postProcessingView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          [UIScreen mainScreen].applicationFrame.size.width,
                                                                          [UIScreen mainScreen].applicationFrame.size.height)];
    
    postProcessingView.backgroundColor = [UIColor clearColor];
    
    self.view = postProcessingView;
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    
    self.noiseImageView = [[UIImageView alloc] initWithImage:[BDPostProcessingViewController noiseTextures].lastObject];
    self.noiseImageView.frame = self.view.bounds;
    self.noiseImageView.alpha = arc4random_uniform(100) / 6000.0 + 0.1;
    [self.view addSubview:self.noiseImageView];
    self.view.userInteractionEnabled = NO;
    self.noiseImageView.userInteractionEnabled = NO;
    self.noiseImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    
    self.noiseTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(changeNoise) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_noiseTimer invalidate];
}

- (void)dealloc
{
    [_noiseTimer invalidate];
}

- (void)changeNoise
{
    NSArray *noiseTextures = [BDPostProcessingViewController noiseTextures];
    UIImage *noiseImage = noiseTextures[arc4random_uniform(noiseTextures.count)];
    self.noiseImageView.image = noiseImage;
    self.noiseImageView.alpha = arc4random_uniform(100) / 6000.0 + 0.1;
}

- (void)static
{
    self.flickerView.alpha = 1.0;
    
    int64_t delayInMilliseconds = 300;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInMilliseconds * NSEC_PER_MSEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.flickerView.alpha = 0.3;
        int64_t delayInMilliseconds = 300;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInMilliseconds * NSEC_PER_MSEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.flickerView.alpha = 0.9;
            int64_t delayInMilliseconds = 100;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInMilliseconds * NSEC_PER_MSEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.flickerView.alpha = 0.1;
                int64_t delayInMilliseconds = 200;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInMilliseconds * NSEC_PER_MSEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    self.flickerView.alpha = 0.4;
                    int64_t delayInMilliseconds = 500;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInMilliseconds * NSEC_PER_MSEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        self.flickerView.alpha = 0.2;
                        int64_t delayInMilliseconds = 300;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInMilliseconds * NSEC_PER_MSEC);
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            self.flickerView.alpha = 0.8;
                            int64_t delayInMilliseconds = 4500;
                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInMilliseconds * NSEC_PER_MSEC);
                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                self.flickerView.alpha = 0.4;
                            });
                        });
                    });
                });
            });
        });
    });
}

@end
