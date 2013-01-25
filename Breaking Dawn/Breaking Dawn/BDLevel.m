//
//  BDLevel.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/25/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDLevel.h"

@interface BDLevel () // Private setter

@property (strong, readwrite, nonatomic) UIImage *diffuseMap;

@property (strong, readwrite, nonatomic) UIImage *lightMap;

@property (strong, readwrite, nonatomic) UIImage *collisionMap;

@property (assign, readwrite, nonatomic) CGSize size;

@property (assign, readwrite, nonatomic) CGPoint spawn;

+ (NSArray*)getRGBAsFromImage:(UIImage*)image atX:(int)xx andY:(int)yy count:(int)count;

@end


@implementation BDLevel

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        self.diffuseMap = [UIImage imageNamed:[name stringByAppendingString:@"_diffuse"]];
        self.lightMap = [UIImage imageNamed:[name stringByAppendingString:@"_light"]];
        self.collisionMap = [UIImage imageNamed:[name stringByAppendingString:@"_collision"]];
        
        CGSize imageSize = self.diffuseMap.size;
        
        self.spawn = CGPointMake(imageSize.width/2.0, imageSize.height/2.0);
        
        self.size = imageSize;
    }
    return self;
}

+ (BDLevel *)levelNamed:(NSString *)name
{
    BDLevel *level = [[BDLevel alloc] initWithName:name];
    return level;
}

- (BOOL)canMoveFrom:(CGPoint)from to:(CGPoint)to
{
    return [self canMoveFrom:from to:to withLightLimit:CGFLOAT_MAX];
}

- (BOOL)canMoveFrom:(CGPoint)from to:(CGPoint)to withLightLimit:(CGFloat)lightLimit
{
    // Check collision map for obsacles along the path from 'from' to 'to'
    // If a value in the light map is higher than 'lightLimit', it counts as an obstacle too!
    
    CGPoint currentPoint = CGPointMake(floor(from.x), floor(from.y));
    to = CGPointMake(floor(to.x), floor(to.y));
    
    while (!CGPointEqualToPoint(currentPoint, to)) {
        // Check obstacles
        NSLog(@"%@ %@", NSStringFromCGPoint(currentPoint), NSStringFromCGPoint(to));
        
        CGPoint move = CGPointMake(to.x - currentPoint.x, to.y - currentPoint.y);
        move = CGPointMake(move.x / MAX(move.x, move.y), move.y / MAX(move.x, move.y));
        move = CGPointMake(floor(move.x), floor(move.y));
        currentPoint = CGPointApplyAffineTransform(currentPoint, CGAffineTransformMakeTranslation(move.x, move.y));
    }
    
    UIColor *color = [[BDLevel getRGBAsFromImage:self.collisionMap atX:0 andY:0 count:1] lastObject];
}

+ (NSArray*)getRGBAsFromImage:(UIImage*)image atX:(int)xx andY:(int)yy count:(int)count
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
    
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
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
    
    free(rawData);
    
    return result;
}

@end
