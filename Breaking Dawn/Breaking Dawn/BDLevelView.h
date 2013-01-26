//
//  BDLevelView.h
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/25/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDLevel.h"


@interface BDLevelView : UIView<BDLevelDelegate>

@property (strong, readonly, nonatomic) BDLevel *level;

@property (strong, readonly, nonatomic) UIView *playerLayer;

@property (strong, readonly, nonatomic) UIView *lightLayer;

@property (strong, readonly, nonatomic) UIView *surfaceLayer;

@property (assign, readwrite, nonatomic) CGFloat lightScale;

@property (assign, readwrite, nonatomic) CGFloat pulse;

- (id)initWithLevel:(BDLevel *)level;

- (void)reloadData;

@end
