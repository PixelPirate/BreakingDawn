//
//  BDLightView.h
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/30/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BDLevel;

@interface BDLightView : UIView

@property (assign, readonly, nonatomic) CGFloat radius;

@property (assign, readwrite, nonatomic) CGFloat reliability; // From 1.0 to 0.0. Lower reliability means more flickering.

- (id)initWithPosition:(CGPoint)position inLevel:(BDLevel *)level;

- (CGFloat)illuminationOfPoint:(CGPoint)point;

- (void)setRadius:(CGFloat)radius animated:(BOOL)animated;

@end
