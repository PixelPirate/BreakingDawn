//
//  BDVectorizer.h
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/31/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BDImageMap;

@interface BDVectorizer : NSObject

- (id)initWithMap:(BDImageMap *)imageMap;

@property (strong, readonly, nonatomic) NSArray *corners;

@end
