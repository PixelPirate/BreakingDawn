//
//  BDLevel.h
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/25/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDImageMap.h"
#import <Foundation/Foundation.h>

@interface BDLevel : NSObject

@property (strong, readonly, nonatomic) UIImage *diffuseMap;

@property (strong, readonly, nonatomic) BDImageMap *lightMap;

@property (strong, readonly, nonatomic) BDImageMap *collisionMap;

@property (assign, readonly, nonatomic) CGSize size;

@property (assign, readonly, nonatomic) CGPoint spawn;

@property (strong, readonly, nonatomic) NSMutableArray *lights;

@property (strong, readonly, nonatomic) NSMutableArray *mobs;

@property (assign, readwrite, nonatomic) CGFloat lightScale;

@property (strong, readwrite, nonatomic) NSMutableArray *hotspots;

- (id)initWithName:(NSString *)name;

+ (BDLevel *)levelNamed:(NSString *)name;

- (BOOL)canMoveFrom:(CGPoint)from to:(CGPoint)to;

- (BOOL)canMoveFrom:(CGPoint)from to:(CGPoint)to withLightLimit:(CGFloat)lightLimit;

@end

@interface BDLevel (LevelOneExtras)

@property (strong, readwrite, nonatomic) NSMutableArray *secondLights;

@end
