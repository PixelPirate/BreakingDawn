//
//  BDImage.m
//  Breaking Dawn
//
//  Created by Hendrik Klindworth on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDImageMap.h"

@interface BDImageMap ()

@property (strong, readwrite, nonatomic) UIImage *image;
@property (strong, readwrite, nonatomic) NSData *data;
@property (assign, readwrite, nonatomic) NSUInteger bytesPerPixel;
@property (assign, readwrite, nonatomic) NSUInteger bytesPerRow;
@property (assign, readwrite, nonatomic) CGSize size;

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
        self.size = CGSizeMake(width, height);
        self.bytesPerPixel = 4;
        self.bytesPerRow = self.bytesPerPixel * width;
        NSUInteger bitsPerComponent = 8;
        
        unsigned const char *rawData = (unsigned char *)calloc(height * width * 4, sizeof(unsigned char));
        // First get the image into your data buffer
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
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

- (unsigned const char)getByteFromX:(int)x andY:(int)y component:(int)component
{
    unsigned const char *rawData = self.data.bytes;
    int byteIndex = (self.bytesPerRow * y) + x * self.bytesPerPixel + component;
    return rawData[byteIndex];
}

@end
