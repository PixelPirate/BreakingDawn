//
//  UIImage+UIImage_Extras.h
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIImage_Extras)

+ (UIImage *)maskView:(UIView *)view withMask:(UIImage *)maskImage;

+ (NSArray*)getRGBAsFromImage:(UIImage*)image atX:(int)xx andY:(int)yy count:(int)count;

@end
