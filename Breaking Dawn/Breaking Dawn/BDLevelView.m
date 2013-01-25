//
//  BDLevelView.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/25/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDLevelView.h"
#import "BDLevel.h"

@interface BDLevelView ()

@property (strong, readwrite, nonatomic) UIImageView *diffuseMapView;

@end


@implementation BDLevelView

- (id)initWithLevel:(BDLevel *)level
{
    CGFloat scale = [[NSUserDefaults standardUserDefaults] floatForKey:@"Scale"];
    
    self = [super initWithFrame:CGRectMake(0, 0, level.size.width*scale, level.size.height*scale)];
    if (self) {
        self.diffuseMapView = [[UIImageView alloc] initWithImage:level.diffuseMap];
        self.diffuseMapView.frame = self.bounds;
        [self addSubview:self.diffuseMapView];
    }
    return self;
}

@end
