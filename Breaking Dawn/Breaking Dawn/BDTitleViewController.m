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

@interface NSString (FU)
- (CGFloat)fontSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
@end

@implementation NSString (FU)

- (CGFloat)fontSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size {
    CGFloat fontSize = [font pointSize];
    CGFloat height = [self sizeWithFont:font constrainedToSize:CGSizeMake(size.width,FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height;
    UIFont *newFont = font;
    
    //Reduce font size while too large, break if no height (empty string)
    while (height > size.height && height != 0) {
        fontSize--;
        newFont = [UIFont fontWithName:font.fontName size:fontSize];
        height = [self sizeWithFont:newFont constrainedToSize:CGSizeMake(size.width,FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height;
    };
    
    // Loop through words in string and resize to fit
    for (NSString *word in [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]) {
        CGFloat width = [word sizeWithFont:newFont].width;
        while (width > size.width && width != 0) {
            fontSize--;
            newFont = [UIFont fontWithName:font.fontName size:fontSize];
            width = [word sizeWithFont:newFont].width;
        }
    }
    return fontSize;
}

@end


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
    
    self.logoView.alpha = 1.0;
    self.button.alpha = 1.0;
    self.titleText.alpha = 1.0;
    self.view.backgroundColor = [UIColor clearColor];
    
    self.logoView.alpha = 0.0;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                         0,
                                                         [UIScreen mainScreen].bounds.size.width,
                                                         [UIScreen mainScreen].bounds.size.height)];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    
    self.titleText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width*0.8, self.view.bounds.size.height / 2.0)];
    self.titleText.text = @"Nykto";
    self.titleText.font = [UIFont fontWithName:@"Chalkduster" size:[UIFont labelFontSize]*140.0];
    self.titleText.adjustsFontSizeToFitWidth = YES;
    self.titleText.numberOfLines = 1;
    self.titleText.textAlignment = NSTextAlignmentCenter;
    self.titleText.center = CGPointMake(self.view.bounds.size.width / 2.0, self.titleText.bounds.size.height/2.0);
    self.titleText.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.titleText.backgroundColor = [UIColor clearColor];
    self.titleText.textColor = [UIColor whiteColor];
    CGFloat fontSize = [self.titleText.text fontSizeWithFont:self.titleText.font constrainedToSize:self.titleText.frame.size];
    self.titleText.font = [UIFont fontWithName:@"Chalkduster" size:fontSize];
    
    [self.view addSubview:self.titleText];
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIEdgeInsets insets = UIEdgeInsetsMake(5.0, 0.0, 0.0, 0.0);
    self.button.frame = CGRectMake(0 + insets.left,
                                   self.titleText.frame.origin.y + self.titleText.bounds.size.height + insets.top,
                                   self.view.bounds.size.width + insets.right,
                                   70 + insets.bottom);
    self.button.contentMode = UIViewContentModeScaleAspectFit;
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
    self.gameViewController = [[BDGameViewController alloc] initWithNibName:nil bundle:nil];
    
    [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
        self.logoView.alpha = 0.0;
        self.button.alpha = 0.0;
        self.titleText.alpha = 0.0;
        self.view.backgroundColor = [UIColor blackColor];
    } completion:^(BOOL finished) {
        [self.postEffectsController.view removeFromSuperview];
        self.postEffectsController = nil;
        
        self.gameViewController.view.frame = self.view.bounds;
        [self.view addSubview:self.gameViewController.view];
    }];
}

- (void)presentTitleScreen
{
    [UIView animateWithDuration:2.5 delay:0.0 options:0 animations:^{
        self.gameViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.gameViewController.view removeFromSuperview];
        self.gameViewController = nil;
        
        [self.postEffectsController.view removeFromSuperview];
        self.postEffectsController = [[BDPostProcessingViewController alloc] initWithNibName:nil bundle:nil];
        self.postEffectsController.view.frame = self.view.bounds;
        [self.view addSubview:self.postEffectsController.view];
        
        [UIView animateWithDuration:2.0 animations:^{
            self.button.alpha = 1.0;
            self.titleText.alpha = 1.0;
            self.view.backgroundColor = [UIColor clearColor];
        }];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
