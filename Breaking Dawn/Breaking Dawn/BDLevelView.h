//
//  BDLevelView.h
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/25/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BDLevelView;
@class BDLevel;

@protocol BDLevelViewDataSource <NSObject>

@required

- (NSArray *)lightsInLevelView:(BDLevelView *)levelView;

- (CGFloat)lightScaleInLevelView:(BDLevelView *)levelView;

@end


@interface BDLevelView : UIView

@property (weak, readwrite, nonatomic) id<BDLevelViewDataSource> dataSource;

@property (weak, readonly, nonatomic) BDLevel *level;

@property (strong, readonly, nonatomic) UIView *playerLayer;

@property (strong, readonly, nonatomic) UIView *lightLayer;

@property (strong, readonly, nonatomic) UIView *surfaceLayer;

@property (assign, readonly, nonatomic) CGFloat lightScale;

@property (assign, readwrite, nonatomic) CGFloat pulse;

- (id)initWithLevel:(BDLevel *)level;

- (void)reloadData;

@end
