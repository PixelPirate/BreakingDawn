//
//  BDImage.m
//  Breaking Dawn
//
//  Created by Hendrik Klindworth on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDImageMap.h"

@interface BDImageMap ()

@property (readwrite, nonatomic) UIImage *image;

@end

@implementation BDImageMap


- (BDImageMap *)initWithUIImage:(UIImage *)image
{
    self = [super init];
    self.image = image;
    return self;
}

- (NSArray*)getRGBAsFromImageX:(int)xx andY:(int)yy count:(int)count
{
    static NSCache *cachedImages = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cachedImages = [[NSCache alloc] init];
    });
    
    unsigned const char *rawData = [[cachedImages objectForKey:self.image] bytes];
    
    CGImageRef imageRef = [self.image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    if (rawData == NULL) {
        // First get the image into your data buffer
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
        CGContextRef context = CGBitmapContextCreate((void *)rawData, width, height,
                                                     bitsPerComponent, bytesPerRow, colorSpace,
                                                     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGColorSpaceRelease(colorSpace);
        
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        CGContextRelease(context);
        
        [cachedImages setObject:[NSData dataWithBytesNoCopy:(void *)rawData
                                                     length:(height * width * 4 * sizeof(unsigned char))
                                               freeWhenDone:YES] forKey:self.image];
    }
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    int byteIndex = (bytesPerRow * yy) + xx * bytesPerPixel;
    for (int ii = 0 ; ii < count ; ++ii)
    {
        CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
        CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
        CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
        CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
        byteIndex += 4;
        
        UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        [result addObject:acolor];
    }
    
    //free(rawData);
    
    return result;
}

@end
