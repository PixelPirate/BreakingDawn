//
//  BDVectorizer.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/31/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDVectorizer.h"
#import "BDCornerDetector.h"
#import "BDImageMap.h"

@interface BDVectorizer ()

@property (strong, readwrite, nonatomic) NSArray *corners;

@property (strong, readwrite, nonatomic) BDImageMap *imageMap;

@end


@implementation BDVectorizer

- (id)initWithMap:(BDImageMap *)imageMap
{
    self = [super init];
    if (self) {
        self.corners = nil;
        self.imageMap = imageMap;
    }
    return self;
}

- (NSArray *)corners
{
    if (_corners == nil) {
        NSMutableArray *detectedCorners = [NSMutableArray array];
        id<BDFeatureDetector> detector = [[BDCornerDetector alloc] init];
        NSInteger weights[(NSInteger)self.imageMap.size.width][(NSInteger)self.imageMap.size.height];
        NSInteger max = NSIntegerMin;
        for (NSUInteger x = 0; x+2 < self.imageMap.size.width; ++x) {
            for (NSUInteger y = 0; y+2 < self.imageMap.size.height; ++y) {
                unsigned char N8[9];
                N8[0] = [self.imageMap getByteFromX:x   andY:y   component:0] > 120 ? 1 : 0;
                N8[1] = [self.imageMap getByteFromX:x+1 andY:y   component:0] > 120 ? 1 : 0;
                N8[2] = [self.imageMap getByteFromX:x+2 andY:y   component:0] > 120 ? 1 : 0;
                N8[3] = [self.imageMap getByteFromX:x   andY:y+1 component:0] > 120 ? 1 : 0;
                N8[4] = [self.imageMap getByteFromX:x+1 andY:y+1 component:0] > 120 ? 1 : 0;
                N8[5] = [self.imageMap getByteFromX:x+2 andY:y+1 component:0] > 120 ? 1 : 0;
                N8[6] = [self.imageMap getByteFromX:x   andY:y+2 component:0] > 120 ? 1 : 0;
                N8[7] = [self.imageMap getByteFromX:x+1 andY:y+2 component:0] > 120 ? 1 : 0;
                N8[8] = [self.imageMap getByteFromX:x+2 andY:y+2 component:0] > 120 ? 1 : 0;
                
                NSInteger weight = [detector test:[NSData dataWithBytesNoCopy:N8 length:9 freeWhenDone:NO]];
                weights[x][y] = ABS(weight);
                if (ABS(weight) > max) {
                    max = ABS(weight);
                }
            }
        }
        for (NSUInteger x = 0; x < (NSInteger)self.imageMap.size.width; ++x) {
            for (NSUInteger y = 0; y < (NSInteger)self.imageMap.size.height; ++y) {
                if (weights[x][y] == max) {
                    [detectedCorners addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                }
            }
        }
        self.corners = [NSArray arrayWithArray:detectedCorners];
    }
    
    return _corners;
}

@end
