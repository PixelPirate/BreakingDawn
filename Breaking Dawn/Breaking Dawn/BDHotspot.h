//
//  BDHotspot.h
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDHotspot : NSObject

@property (assign, readwrite, nonatomic) CGRect frame;

@property (assign, readwrite, nonatomic) BOOL toggle;

- (id)initWithFrame:(CGRect)frame trigger:(void(^)())trigger;

- (void)test:(CGPoint)position;

@end
