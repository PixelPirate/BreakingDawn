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

- (void)line:(CGPoint)from to:(CGPoint)to usingBlock:(void (^)(int x, int y))block
{
    float x0=from.x, y0=from.y;
    float x1=to.x, y1=to.y;
    
    // Check if x difference is bigger than y differene, than swap now and later call block swapped
    bool steep = (abs(y1-y0) > abs(x1-x0));
    if(steep) {
        float swap;
        swap=y0; x0=y0; y0=swap;
        swap=y1; x1=y1; y1=swap;
    }
    
    // Run from left to right or from right to left
    int inc = x1 > x0 ? 1 : -1;
    
    for(int x=x0; (inc>0) ? (x<=x1) : (x>=x1); x+=inc) {
        float progress = (x-x0)/(x1-x0);
        int y = y0 + (y1-y0)*progress;
        if(steep) block(x, y); else block(y, x);
    }
}

- (BOOL)canMoveFrom:(CGPoint)from to:(CGPoint)to withLightLimit:(CGFloat)lightLimit
{
    // Check collision map for obsacles along the path from 'from' to 'to'
    // If a value in the light map is higher than 'lightLimit', it counts as an obstacle too!
    
    //NSLog(@"%@ %@ %@", NSStringFromSelector(_cmd), NSStringFromCGPoint(from), NSStringFromCGPoint(to));
    
    [self line:from to:to usingBlock:^(int x, int y) {
        UIColor *color = [[BDLevel getRGBAsFromImage:self.diffuseMap atX:x andY:y count:1] lastObject];
        NSLog(@"%d %d", x, y);
    }];
    
    
    return YES;
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
