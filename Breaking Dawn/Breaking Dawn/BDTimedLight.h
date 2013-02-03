//
//  BDTimedLight.h
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 2/3/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDLight.h"

@interface BDTimedLight : BDLight

@property (assign, readwrite, nonatomic) CGPoint location;

@property (assign, readonly, nonatomic) BOOL visible;

@end
