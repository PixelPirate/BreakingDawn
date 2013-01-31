//
//  BDCornerDetector.h
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/31/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BDFeatureDetector <NSObject>

- (NSInteger)test:(NSData *)data;
// Data shall be interpreted as quad of size: sqrt(size) * sqrt(size)
// The each byte shall be an boolean value indicating black/white.
// Note: We actually only implemented N8 neiborhood.

@end

@interface BDCornerDetector : NSObject<BDFeatureDetector>

@end
