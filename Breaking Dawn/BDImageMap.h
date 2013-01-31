//
//  BDImage.h
//  Breaking Dawn
//
//  Created by Hendrik Klindworth on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDImageMap : NSObject

@property (assign, readonly, nonatomic) CGSize size;

@property (assign, readonly, nonatomic) NSUInteger bytesPerPixel;

- (BDImageMap *)initWithUIImage:(UIImage *)image;

- (unsigned const char)getByteFromX:(int)x andY:(int)y component:(int)component;

@end