//
//  BDLevel.h
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/25/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDImageMap.h"
#import <Foundation/Foundation.h>
#import "BDLevelView.h"

@class BDLevel;


@protocol BDLevelDelegate <NSObject> // These callbacks are due to notify about dynamic changes to the level though its hotspots.

- (void)level:(BDLevel *)level didAddLights:(NSArray *)lights;

- (void)levelWillWin:(BDLevel *)level;

@end


@interface BDLevel : NSObject<BDLevelViewDataSource>

@property (strong, readonly, nonatomic) UIImage *diffuseMap;

//@property (strong, readonly, nonatomic) BDImageMap *lightMap;

@property (strong, readonly, nonatomic) BDImageMap *collisionMap;

@property (assign, readonly, nonatomic) CGSize size;

@property (assign, readonly, nonatomic) CGPoint spawn;

@property (strong, readonly, nonatomic) NSMutableArray *lights;

@property (strong, readonly, nonatomic) NSMutableArray *mobs;

@property (assign, readwrite, nonatomic) CGFloat lightScale;

@property (strong, readwrite, nonatomic) NSMutableArray *hotspots;

@property (strong, readonly, nonatomic) NSDictionary *stages;

@property (weak, readwrite, nonatomic) id<BDLevelDelegate> delegate;

@property (assign, readwrite, nonatomic) BOOL lightSwitchVisible;

- (id)initWithName:(NSString *)name;

+ (BDLevel *)levelNamed:(NSString *)name;

- (BOOL)isFreeX:(int)x andY:(int)y;

- (BOOL)canMoveFrom:(CGPoint)from to:(CGPoint)to;

- (BOOL)noLightsFrom:(CGPoint)from to:(CGPoint)to;

- (void)evaluatePointsOnLineFrom:(CGPoint)from to:(CGPoint)to usingBlock:(void (^)(CGPoint point, BOOL *stop))block;

- (NSArray *)corners;

@end
