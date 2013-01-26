//
//  BDMobView.h
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BDMob;

@interface BDMobView : UIView

@property (strong, readonly, nonatomic) BDMob *mob;

- (id)initWithMob:(BDMob *)mob;

@end
