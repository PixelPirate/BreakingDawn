//
//  BDHotspot.h
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BDLevel;


@interface BDHotspot : NSObject

@property (assign, readwrite, nonatomic) CGRect frame;

@property (assign, readwrite, nonatomic) BOOL toggle;

@property (strong, readwrite, nonatomic) NSDictionary *activeDecal;

@property (strong, readwrite, nonatomic) NSDictionary *inactiveDecal;

@property (assign, readonly, nonatomic) NSInteger state;

//- (id)initWithFrame:(CGRect)frame trigger:(void(^)())trigger;

- (id)initWithFrame:(CGRect)frame changes:(NSArray *)changes level:(BDLevel *)level;

- (id)initWithFrame:(CGRect)frame stageChange:(NSString *)stage level:(BDLevel *)level;

- (id)initWithFrame:(CGRect)frame levelChange:(NSString *)levelName level:(BDLevel *)level;

- (void)test:(CGPoint)position;

@end
