//
//  BDPlayer.h
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/25/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^AdrenalinHandler)(void);


@class BDPlayer;

@protocol BDPlayerDelegate <NSObject>

- (void)playerDidMove:(BDPlayer *)player toPosition:(CGPoint)position;

@end


@interface BDPlayer : NSObject

@property (weak, readwrite, nonatomic) id<BDPlayerDelegate> delegate;

@property (assign, readwrite, nonatomic) CGFloat adrenalin;

@property (assign, readonly, nonatomic) CGPoint lastLocation;

@property (assign, readwrite, nonatomic) CGPoint location;

@property (assign, readwrite, nonatomic) CGPoint direction;

@property (copy, readwrite, nonatomic) AdrenalinHandler adrenalinHandler;

@property (assign, readonly, nonatomic) CGFloat lastLuminance;

@property (assign, readonly, nonatomic) CGFloat luminanceDelta;

- (id)initWithPosition:(CGPoint)position;

- (void)updateAdrenalin:(CGFloat)luminance;

@end
