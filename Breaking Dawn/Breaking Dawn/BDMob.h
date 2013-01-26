//
//  BDMob.h
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BDMob;

@protocol BDMobDelegate <NSObject>

- (void)mobCollidedWithPlayer:(BDMob *)mob;

- (void)mobDidMove:(BDMob *)mob toPosition:(CGPoint)position;

@end


@interface BDMob : NSObject

@property (assign, readwrite, nonatomic) CGPoint location;

@property (weak, readwrite, nonatomic) id<BDMobDelegate> delegate;

- (id)initWithPosition:(CGPoint)position;

@end
