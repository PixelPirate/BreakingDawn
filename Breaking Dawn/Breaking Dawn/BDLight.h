//
//  BDLight.h
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 2/3/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BDPlayer;

/**
 * @description BDLight class cluster
 */
@interface BDLight : NSObject

+ (BDLight *)lightWithDuration:(NSTimeInterval)duration
              reappearIntetval:(NSTimeInterval)reappear
               playerTriggered:(BOOL)player
                      location:(CGPoint)location;
+ (BDLight *)timedLight;
+ (BDLight *)trapLight;
+ (BDLight *)light;

- (id)initWithDuration:(NSTimeInterval)duration
      reappearIntetval:(NSTimeInterval)reappear
       playerTriggered:(BOOL)player
              location:(CGPoint)location;

- (void)evaluateForDelta:(NSTimeInterval)delta
                  player:(BDPlayer *)player
                  radius:(CGFloat)radius
               triggered:(void (^)(BDLight *theLight))triggered;

- (void)setLocation:(CGPoint)location;
- (CGPoint)location;
- (BOOL)visible;
- (void)setAppeared:(CFAbsoluteTime)appeared;

@end
