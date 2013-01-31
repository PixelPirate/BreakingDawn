//
//  BDCornerDetector.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/31/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDCornerDetector.h"

@implementation BDCornerDetector

- (NSInteger)test:(NSData *)data
{
    NSAssert(data.length == 9, @"Only N8 neigborhoods are supportet at the moment.");
    NSAssert(sqrt(data.length)*sqrt(data.length) == data.length, @"");
    NSUInteger edgeLength = sqrt(data.length);
    
    // Fuck it, we just implement N8 neigborhood!
    int8_t a[3][3] = {{-1, 0, 0}, {0, 0, 0}, {0, 0, 1}};
    int8_t b[3][3] = {{0, 0, -1}, {0, 0, 0}, {1, 0, 0}};
    
    NSInteger(^weight)(int8_t[3][3]) = ^(int8_t m[3][3]) {
        NSInteger weight = 0;
        for (NSUInteger x = 0; x < edgeLength; ++x) {
            for (NSUInteger y = 0; y < edgeLength; ++y) {
                uint8_t value = ((uint8_t *)data.bytes)[(edgeLength*x)+y];
                
                weight += value * m[x][y];
            }
        }
        return weight;
    };
    
    NSInteger totalWeight = 0;
    totalWeight += weight(a);
    totalWeight += weight(b);
    
    return totalWeight;
}

@end
