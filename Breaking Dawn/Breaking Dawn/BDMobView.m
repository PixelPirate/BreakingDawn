//
//  BDMobView.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDMobView.h"
#import "BDMob.h"

@interface BDMobView () // Private setter

@property (weak, readwrite, nonatomic) BDMob *mob;

@property (strong, readwrite, nonatomic) UIImage *mobImage;

@property (strong, readwrite, nonatomic) UIImageView *mobImageView;

@property (strong, readwrite, nonatomic) NSTimer *dismissTimer;

- (void)dismiss;

@end


@implementation BDMobView

- (id)initWithMob:(BDMob *)mob
{
    CGFloat scale = [[NSUserDefaults standardUserDefaults] floatForKey:@"Scale"];
    UIImage *mobImage = [UIImage imageNamed:@"mob00-01"];
    
    self = [super initWithFrame:CGRectMake(0, 0, mobImage.size.width*scale, mobImage.size.height*scale)];
    if (self) {
        self.mob = mob;
        self.mobImage = mobImage;
        self.mobImageView = [[UIImageView alloc] initWithImage:self.mobImage];
        self.mobImageView.frame = self.bounds;
        CGPoint center = mob.location;
        center = CGPointApplyAffineTransform(center, CGAffineTransformMakeScale(scale, scale));
        self.center = center;
        [self addSubview:self.mobImageView];
        self.mob.delegate = self;
    }
    return self;
}

- (void)dismiss
{
    self.hidden = YES;
    [self.mob return];
    CGFloat scale = [[NSUserDefaults standardUserDefaults] floatForKey:@"Scale"];
    CGPoint center = self.mob.location;
    center = CGPointApplyAffineTransform(center, CGAffineTransformMakeScale(scale, scale));
    self.center = center;
}

#pragma mark - BDMobDelegate implementations

- (void)mobDidMove:(BDMob *)mob toPosition:(CGPoint)position
{
    self.hidden = NO;
    [self.dismissTimer invalidate];
    
    CGFloat scale = [[NSUserDefaults standardUserDefaults] floatForKey:@"Scale"];
    CGPoint center = position;
    center = CGPointApplyAffineTransform(center, CGAffineTransformMakeScale(scale, scale));
    self.center = center;
    
    self.dismissTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
}

@end
