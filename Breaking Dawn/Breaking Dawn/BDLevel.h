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


/*
 
 Dynamic Level Format
 
 {
    Background : map00_diffuse
    Collision  : map00_collision
    0 : {                                                  // Initial layout of the level
            Spawn     : [0, 0]
            MobSpawns : [[1, 1], [2, 2], [3, 3]]
            Lights    : [[1, 1], [2, 2], [3, 3]]
            Hotspots  : [{
                            Area   : [5, 5, 10, 10]
                            Stage  : 1                     // Stage to load when hotspot is triggered
                            Repeat : NO                    // Hotspot will invalidate after it is triggered the first time
                        }]
        }
    1 : {
            Spawn     : [5, 5]                             // Overwrites old spawn, aka "Checkpoint"
            MobSpawns : [[10, 10], [2, 2]]                 // One enemy did disappear, one did join the fight
            Lights    : [[2, 2], [3, 3], [4, 4]]           // One light appeard, one disappeard
            TrapLights : [{
                            Position : [1, 1]              // One light "changed" to an fragile light. (Explodes after 'duration' seconds)
                            Duration : 5
                            Reappear : 0                   // Takes 'reappear' seconds til the light goes on again. Zero equals never
                        }]
            TimeLights: [{
                            Position  : [6, 6]             // Can be used to force the player move forward, or for interval lights
                            Disappear : 15                 // Light will dissapear after 15 seconds from game start
                            Reappear  : 15                 // And reappear after 15 more seconds. Will never reappear when zero
                        }]
            Hotspots  : [{
                            Area   : [15, 15, 10, 10]
                            Stage  : 2
                            Repeat : NO
                        },
                        {
                            Area    : [20, 20, 10, 10]
                            Repeat  : YES
                            Changes : [{                                        // Alternative to 'Stage'. Allows more fine tuned actions.
                                        RemoveLights : [[3, 3]]                 // Remove light at [3, 3]
                                        AddBadLights : [{                       // Replace with BadLight
                                                            Position : [3, 3]
                                                            Duration : 5
                                                            Reappear : 5
                                                        }]
                                       },{                                   // On each repeat, the hotspot cycles through the changes list
                                        RemoveLights : [[3, 3]]              // Remove the BadLight
                                        AddLights : [[3, 3]]                 // Add an normal light instead
                                       }]
                        }]
        }
    2 : {
            Level    : Credits                             // Transition to a different level, game over screen or the credits
        }
    3 : {
            Level    : Cellar                              // Name of the next level
        }
 }
 */





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

// Data models are always in the map coordinate system (The original size of the background image)
// As such, the light coordinates are also in the images coordinate system. (Like the player spawn for example)
// Convertion to screen positions should be done in the views (see the last part in playerDidMove:toPosition: in BDPlayerView).
// This makes usage of the canMoveFrom:to: kind of methods easier, as they operate on the image and thus need image coordinates.
@property (strong, readonly, nonatomic) NSMutableArray *lights;

@property (strong, readonly, nonatomic) NSMutableArray *trapLights;

@property (strong, readonly, nonatomic) NSMutableArray *timedLights;

@property (strong, readonly, nonatomic) NSMutableArray *mobs;

@property (assign, readwrite, nonatomic) CGFloat lightScale;

@property (strong, readwrite, nonatomic) NSMutableArray *hotspots;

@property (strong, readonly, nonatomic) NSDictionary *stages;

@property (strong, readonly, nonatomic) NSArray *decals;

@property (weak, readwrite, nonatomic) id<BDLevelDelegate> delegate;

//@property (assign, readwrite, nonatomic) BOOL lightSwitchVisible;

//- (id)initWithName:(NSString *)name;

- (id)initWithLevelNamed:(NSString *)fileName;


//+ (BDLevel *)levelNamed:(NSString *)name;

- (BOOL)isFreeX:(int)x andY:(int)y;

- (BOOL)canMoveFrom:(CGPoint)from to:(CGPoint)to;

- (BOOL)noLightsFrom:(CGPoint)from to:(CGPoint)to;

- (void)evaluatePointsOnLineFrom:(CGPoint)from to:(CGPoint)to usingBlock:(void (^)(CGPoint point, BOOL *stop))block;

- (NSArray *)convertPositions:(NSArray *)positions;

- (NSValue *)convertPosition:(NSDictionary *)position;

- (NSArray *)corners;

- (void)exchangeDecal:(NSDictionary *)decal withDecal:(NSDictionary *)decal;

- (void)evaluateLightsForPlayerAtPosition:(CGPoint)position;

- (void)levelDidBegin;

@end