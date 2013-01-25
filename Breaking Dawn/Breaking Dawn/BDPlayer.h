//
//  BDPlayer.h
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/25/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BDPlayer;

@protocol BDPlayerDelegate <NSObject>

- (void)playerDidMove:(BDPlayer *)player toPosition:(CGPoint)position;

@end


@interface BDPlayer : NSObject

@property (weak, readwrite, nonatomic) id<BDPlayerDelegate> delegate;

@property (assign, readwrite, nonatomic) CGFloat adrenalin;

@property (assign, readwrite, nonatomic) CGPoint location;

- (id)initWithPosition:(CGPoint)position;

@end
