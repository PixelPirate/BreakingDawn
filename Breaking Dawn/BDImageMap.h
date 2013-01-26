//
//  BDImage.h
//  Breaking Dawn
//
//  Created by Hendrik Klindworth on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDImageMap : NSObject

- (BDImageMap *)initWithUIImage:(UIImage *)image;
- (NSArray*)getRGBAsFromImageX:(int)xx andY:(int)yy count:(int)count;

@end