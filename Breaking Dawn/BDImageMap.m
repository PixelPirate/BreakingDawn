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
@property (readwrite, nonatomic) NSData *data;
@property (readwrite, nonatomic) NSUInteger bytesPerPixel;
@property (readwrite, nonatomic) NSUInteger bytesPerRow;

@end

@implementation BDImageMap


- (BDImageMap *)initWithUIImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        self.image = image;
        
        CGImageRef imageRef = [self.image CGImage];
        NSUInteger width = CGImageGetWidth(imageRef);
        NSUInteger height = CGImageGetHeight(imageRef);
        self.bytesPerPixel = 4;
        self.bytesPerRow = self.bytesPerPixel * width;
        NSUInteger bitsPerComponent = 8;
        
        unsigned const char *rawData;
        // First get the image into your data buffer
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
        CGContextRef context = CGBitmapContextCreate((void *)rawData, width, height,
                                                     bitsPerComponent, self.bytesPerRow, colorSpace,
                                                     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGColorSpaceRelease(colorSpace);
        
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        CGContextRelease(context);
        
        self.data = [NSData dataWithBytesNoCopy:(void *)rawData length:height * width * 4 * sizeof(unsigned char) freeWhenDone:YES];
    }
    return self;
}

- (NSArray*)getRGBAsFromImageX:(int)xx andY:(int)yy count:(int)count
{
    unsigned const char *rawData = self.data.bytes;
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    int byteIndex = (self.bytesPerRow * yy) + xx * self.bytesPerPixel;
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
