//
//  BDLevel.h
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/25/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDLevel : NSObject

@property (strong, readonly, nonatomic) UIImage *diffuseMap;

@property (strong, readonly, nonatomic) UIImage *lightMap;

@property (strong, readonly, nonatomic) UIImage *collisionMap;

@property (assign, readonly, nonatomic) CGSize size;

@property (assign, readonly, nonatomic) CGPoint spawn;

@property (strong, readonly, nonatomic) NSMutableArray *lights;

@property (strong, readonly, nonatomic) NSMutableArray *mobs;

- (id)initWithName:(NSString *)name;

+ (BDLevel *)levelNamed:(NSString *)name;

- (BOOL)canMoveFrom:(CGPoint)from to:(CGPoint)to;

- (BOOL)canMoveFrom:(CGPoint)from to:(CGPoint)to withLightLimit:(CGFloat)lightLimit;

@end
