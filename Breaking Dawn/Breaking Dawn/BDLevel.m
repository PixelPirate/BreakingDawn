//
//  BDLevel.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/25/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDLevel.h"
#import "UIImage+UIImage_Extras.h"
#import <QuartzCore/QuartzCore.h>
#import "BDMob.h"
#import "BDImageMap.h"
#import "BDHotspot.h"
#import "BDSound.h"
#import "BDVectorizer.h"
#import "BDLight.h"
#import "BDPlayer.h"

@interface BDLevel () // Private setter

@property (strong, readwrite, nonatomic) UIImage *diffuseMap;

//@property (strong, readwrite, nonatomic) BDImageMap *lightMap;

@property (strong, readwrite, nonatomic) BDImageMap *collisionMap;

@property (assign, readwrite, nonatomic) CGSize size;

@property (assign, readwrite, nonatomic) CGPoint spawn;

@property (strong, readwrite, nonatomic) NSMutableArray *lights;

@property (strong, readwrite, nonatomic) NSMutableArray *trapLights;

@property (strong, readwrite, nonatomic) NSMutableArray *timedLights;

@property (strong, readwrite, nonatomic) NSMutableArray *mobs;

@property (strong, readwrite, nonatomic) NSDictionary *stages;

@property (strong, readwrite, nonatomic) NSArray *decals;

@property (strong, readwrite, nonatomic) NSDate *levelStartingDate;

@property (strong, readwrite, nonatomic) NSDate *previousEvaluationDate;

@property (strong, readwrite, nonatomic) NSDictionary *levelInfo;

@property (strong, readwrite, nonatomic) NSString *stage;

//- (void)loadLightmap;

@end


@implementation BDLevel

- (NSArray *)NSPointsFromArrays:(NSArray *)array
{
    NSMutableArray *points = [NSMutableArray array];
    for (NSArray *pointArray in array) {
        NSValue *point = [NSValue valueWithCGPoint:CGPointMake([pointArray[0] floatValue], [pointArray[1] floatValue])];
        [points addObject:point];
    }
    return points;
}

- (NSArray *)NSRectsFromArrays:(NSArray *)array
{
    NSMutableArray *rects = [NSMutableArray array];
    for (NSArray *rectArray in array) {
        NSValue *rect = [NSValue valueWithCGRect:CGRectMake([rectArray[0] floatValue],
                                                             [rectArray[1] floatValue],
                                                             [rectArray[2] floatValue],
                                                             [rectArray[3] floatValue])];
        [rects addObject:rect];
    }
    return rects;
}

- (id)initWithLevelNamed:(NSString *)fileName
{
    self = [super init];
    if (self) {
        if ([[fileName pathExtension] isEqualToString:@""]) {
            fileName = [fileName stringByAppendingPathExtension:@"json"];
        }
        NSURL *mapURL = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:fileName];
        NSError *error = nil;
        
        self.levelInfo = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:mapURL] options:0 error:&error];
        if (error) {
            NSLog(@"<Warning> Could not load level %@, %@", fileName, error);
            self = nil;
            return self;
        }
        
        NSString *backgroundImageName = self.levelInfo[@"Background"];
        NSString *collisionImageName = self.levelInfo[@"Collision"];
        
        self.diffuseMap = [UIImage imageNamed:backgroundImageName];
        UIImage *collision = [UIImage imageNamed:collisionImageName];
        self.collisionMap = [[BDImageMap alloc] initWithUIImage:collision];
        
        self.lightScale = 1.0;
        
        CGSize imageSize = self.diffuseMap.size;
        self.size = imageSize;
        
        self.decals = [NSArray array];
        
        self.stage = @"0";
        
        [self loadStage:@"0"];
    }
    return self;
}

- (void)exchangeDecal:(NSDictionary *)oldDecal withDecal:(NSDictionary *)decal
{
    NSMutableArray *newDecals = self.decals.mutableCopy;
    if (oldDecal) {
        [newDecals removeObject:oldDecal];
    }
    if (decal) {
        [newDecals addObject:decal];
    }
    self.decals = newDecals;
}

- (NSArray *)convertPositions:(NSArray *)positions
{
    NSMutableArray *pointLights = [NSMutableArray array];
    for (NSDictionary *pointRep in positions) {;
        [pointLights addObject:[self convertPosition:pointRep]];
    }
    return pointLights;
}

- (NSValue *)convertPosition:(NSDictionary *)position
{
    CGFloat scale = [[NSUserDefaults standardUserDefaults] floatForKey:@"Scale"];
    CGPoint light = CGPointMake([position[@"X"] floatValue]*scale, [position[@"Y"] floatValue]*scale);
    return [NSValue valueWithCGPoint:light];
}

- (NSArray *)valuesWithPositions:(NSArray *)positions
{
    NSMutableArray *values = [NSMutableArray array];
    for (NSDictionary *pointRep in positions) {
        [values addObject:[self valueWithPositionDictionary:pointRep]];
    }
    return values;
}

- (NSValue *)valueWithPositionDictionary:(NSDictionary *)position
{
    CGPoint light = CGPointMake([position[@"X"] floatValue], [position[@"Y"] floatValue]);
    return [NSValue valueWithCGPoint:light];
}

+ (BDLevel *)levelNamed:(NSString *)name
{
    BDLevel *level = [[BDLevel alloc] initWithLevelNamed:name];
    return level;
}

- (void)evaluatePointsOnLineFrom:(CGPoint)from to:(CGPoint)to usingBlock:(void (^)(CGPoint, BOOL *))block
{
    float x0 = from.x, y0 = from.y;
    float x1 = to.x,   y1 = to.y;
    
    // Check if x difference is bigger than y differene, than swap now and later call block swapped
    bool steep = (abs(y1 - y0) > abs(x1 - x0));
    if(steep) {
        float swap;
        swap = x0; x0 = y0; y0 = swap;
        swap = x1; x1 = y1; y1 = swap;
    }
    
    // Run from left to right or from right to left
    int inc = x1 > x0 ? 1 : -1;
    
    for(int x = x0; (inc > 0) ? (x <= (int)x1) : (x >= (int)x1); x += inc) {
        float progress = (x - x0) / (x1 - x0);
        int y = y0 + (y1 - y0) * progress;
        BOOL stop = NO;
        if(steep) block(CGPointMake(y, x), &stop); else block(CGPointMake(x, y), &stop);
        if (stop) break;
    }
}

- (BOOL)isFreeX:(int)x andY:(int)y
{
    return ([self.collisionMap getByteFromX:x andY:y component:0] != 0);
}

- (BOOL)canMoveFrom:(CGPoint)from to:(CGPoint)to
{
    // Check collision map for obsacles along the path from 'from' to 'to'
    bool __block canMove = YES;
    [self evaluatePointsOnLineFrom:from to:to usingBlock:^(CGPoint point, BOOL *stop) {
        if([self.collisionMap getByteFromX:point.x andY:point.y component:0] == 0) {
            canMove = NO;
            *stop = YES;
        }
    }];

    return canMove;
}

- (BOOL)noLightsFrom:(CGPoint)from to:(CGPoint)to
{
    // Check if there is a light on the line
    CGFloat fakeRadius = 80.0 * self.lightScale;
    for (NSValue *light in self.lights) {
        CGPoint lightPosition = [light CGPointValue];
        
        if ([self isLineFrom:from to:to withinRadius:fakeRadius fromPoint:lightPosition]) return NO;
    }
    
    return YES;
}

- (BOOL)isLineFrom:(CGPoint)from to:(CGPoint)to withinRadius:(CGFloat)radius fromPoint:(CGPoint)point
{
    CGPoint v = CGPointMake(to.x - from.x, to.y - from.y);
    CGPoint w = CGPointMake(point.x - from.x, point.y - from.y);
    CGFloat c1 = dotProduct(w, v);
    CGFloat c2 = dotProduct(v, v);
    CGFloat d;
    if (c1 <= 0) {
        d = distance(point, from);
    }
    else if (c2 <= c1) {
        d = distance(point, to);
    }
    else {
        CGFloat b = c1 / c2;
        CGPoint Pb = CGPointMake(from.x + b * v.x, from.y + b * v.y);
        d = distance(point, Pb);
    }
    return d <= radius;
}

CGFloat distance(const CGPoint p1, const CGPoint p2) {
    return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2));
}

CGFloat dotProduct(const CGPoint p1, const CGPoint p2) {
    return p1.x * p2.x + p1.y * p2.y;
}

//TODO: Replace with an generic approach
- (NSArray *)corners
{
    return @[
    [NSValue valueWithCGPoint:CGPointMake(50, 700)],
    [NSValue valueWithCGPoint:CGPointMake(50, 800)],
    [NSValue valueWithCGPoint:CGPointMake(236, 319)],
    [NSValue valueWithCGPoint:CGPointMake(236, 705)],
    [NSValue valueWithCGPoint:CGPointMake(542, 518)],
    [NSValue valueWithCGPoint:CGPointMake(542, 800)],
    
    [NSValue valueWithCGPoint:CGPointMake(720, 418)],
    [NSValue valueWithCGPoint:CGPointMake(720, 513)],
    [NSValue valueWithCGPoint:CGPointMake(818, 239)],
    [NSValue valueWithCGPoint:CGPointMake(818, 319)],
    [NSValue valueWithCGPoint:CGPointMake(818, 414)],
    [NSValue valueWithCGPoint:CGPointMake(818, 888)],
    
    [NSValue valueWithCGPoint:CGPointMake(969, 160)],
    [NSValue valueWithCGPoint:CGPointMake(969, 240)],
    
    [NSValue valueWithCGPoint:CGPointMake(1105, 160)],
    [NSValue valueWithCGPoint:CGPointMake(1105, 317)],
    [NSValue valueWithCGPoint:CGPointMake(1105, 415)],
    [NSValue valueWithCGPoint:CGPointMake(1105, 654)],
    
    [NSValue valueWithCGPoint:CGPointMake(1123, 655)],
    [NSValue valueWithCGPoint:CGPointMake(1123, 675)],
    
    [NSValue valueWithCGPoint:CGPointMake(1177, 655)],
    [NSValue valueWithCGPoint:CGPointMake(1177, 675)],
    
    [NSValue valueWithCGPoint:CGPointMake(1300, 250)],
    [NSValue valueWithCGPoint:CGPointMake(1300, 319)],
    [NSValue valueWithCGPoint:CGPointMake(1300, 417)],
    [NSValue valueWithCGPoint:CGPointMake(1300, 597)],
    
    [NSValue valueWithCGPoint:CGPointMake(1414, 122)],
    [NSValue valueWithCGPoint:CGPointMake(1414, 199)],
    
    [NSValue valueWithCGPoint:CGPointMake(1426, 199)],
    [NSValue valueWithCGPoint:CGPointMake(1426, 250)],
    
    [NSValue valueWithCGPoint:CGPointMake(1475, 95)],
    [NSValue valueWithCGPoint:CGPointMake(1475, 116)],
    
    [NSValue valueWithCGPoint:CGPointMake(1650, 95)],
    [NSValue valueWithCGPoint:CGPointMake(1650, 116)],
    
    [NSValue valueWithCGPoint:CGPointMake(1778, 127)],
    [NSValue valueWithCGPoint:CGPointMake(1778, 609)],
    ];
}

/*
- (void)loadLightmap
{
    UIGraphicsBeginImageContext(self.diffuseMap.size);
    [[UIColor blackColor] set];
    UIRectFill(CGRectMake(0, 0, self.diffuseMap.size.width, self.diffuseMap.size.height));
    
    for (NSValue *light in self.lights) {
        CGPoint p = [light CGPointValue];
        
        UIView *light = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 224, 224)];
        light.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.4 alpha:0.8];
        
        UIImage *m = [UIImage maskView:light withMask:[UIImage imageNamed:@"light00-01.jpg"]];
        UIImageView *v = [[UIImageView alloc] initWithImage:m];
        v.center = p;
        
        CGContextSaveGState(UIGraphicsGetCurrentContext());
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), v.frame.origin.x, v.frame.origin.y);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeDestinationOut);
        [v.layer renderInContext:UIGraphicsGetCurrentContext()];
        CGContextRestoreGState(UIGraphicsGetCurrentContext());
    }
    BDImageMap *lightmap = [[BDImageMap alloc] initWithUIImage:UIGraphicsGetImageFromCurrentImageContext()];
    UIGraphicsEndImageContext();
    
    self.lightMap = lightmap;
}
*/
- (void)evaluateLightsForPlayerAtPosition:(CGPoint)position
{
    NSTimeInterval delta = 0.0;
    
    // Trap lights
    CGFloat radius = 80.0 * self.lightScale;
    for (BDLight *trapLightInfo in self.trapLights) {
        __weak id __self = self;
        BDPlayer *player = [[BDPlayer alloc] initWithPosition:position];
        [trapLightInfo evaluateForDelta:delta player:player radius:radius triggered:^(BDLight *theLight) {
            NSValue *center = [NSValue valueWithCGPoint:theLight.location];
            if (theLight.visible) {
                [[__self lights] addObject:center];
            } else {
                [[BDSound sharedSound] playSound:SOUND_LIGHT_EXPLODE];
                [[__self lights] removeObject:center];
            }
        }];
    }
    
    // Timed lights
    for (BDLight *timedLightInfo in self.timedLights) {
        __weak id __self = self;
        BDPlayer *player = [[BDPlayer alloc] initWithPosition:position];
        [timedLightInfo evaluateForDelta:delta player:player radius:radius triggered:^(BDLight *theLight) {
            NSValue *center = [NSValue valueWithCGPoint:theLight.location];
            if (theLight.visible) {
                [[__self lights] addObject:center];
            } else {
                [[BDSound sharedSound] playSound:SOUND_LIGHT_EXPLODE];
                [[__self lights] removeObject:center];
            }
        }];
    }
}

- (void)levelDidBegin
{
    self.levelStartingDate = [NSDate date];
    self.previousEvaluationDate = self.levelStartingDate;
    for (BDLight *aLight in self.timedLights) {
        [aLight setAppeared:CFAbsoluteTimeGetCurrent()];
    }
    for (BDLight *aLight in self.trapLights) {
        [aLight setAppeared:CFAbsoluteTimeGetCurrent()];
    }
}

- (void)loadStage:(NSString *)stageName
{
    NSDictionary *primaryStage = self.levelInfo[stageName];
    NSArray *lightPositions = [self NSPointsFromArrays:primaryStage[@"Lights"]];
    NSArray *trapLights = primaryStage[@"TrapLights"];
    NSArray *timedLights = primaryStage[@"TimedLights"];
    NSArray *mobPositions = [self NSPointsFromArrays:primaryStage[@"MobSpawns"]];
    BOOL updatedPlayerSpawn = NO;
    if (primaryStage[@"Spawn"]) {
        updatedPlayerSpawn = YES;
        CGPoint playerSpawn = CGPointMake([primaryStage[@"Spawn"][0] floatValue], [primaryStage[@"Spawn"][1] floatValue]);
        self.spawn = playerSpawn;
    }
    
    self.lights = [NSMutableArray arrayWithArray:lightPositions];
    self.trapLights = [NSMutableArray array];
    for (NSDictionary *trapLightInfo in trapLights) {
        
        CGPoint location = CGPointMake([trapLightInfo[@"Position"][0] floatValue], [trapLightInfo[@"Position"][1] floatValue]);
        BDLight *trapLight = [BDLight lightWithDuration:[trapLightInfo[@"Duration"] doubleValue]
                                       reappearIntetval:[trapLightInfo[@"Reappear"] doubleValue]
                                        playerTriggered:YES
                                               location:location];
        [self.trapLights addObject:trapLight];
    }
    for (BDLight *trapLightInfo in self.trapLights) {
        [self.lights addObject:[NSValue valueWithCGPoint:trapLightInfo.location]];
    }
    self.timedLights = [NSMutableArray array];
    for (NSDictionary *timedLightInfo in timedLights) {
        
        CGPoint location = CGPointMake([timedLightInfo[@"Position"][0] floatValue], [timedLightInfo[@"Position"][1] floatValue]);
        BDLight *timedLight = [BDLight lightWithDuration:[timedLightInfo[@"Disappear"] floatValue]
                                        reappearIntetval:[timedLightInfo[@"Reappear"] floatValue]
                                         playerTriggered:NO
                                                location:location];
        
        [self.timedLights addObject:timedLight];
        [self.lights addObject:[NSValue valueWithCGPoint:location]];
    }
    
    self.mobs = [NSMutableArray array];
    for (NSValue *pointRep in mobPositions) {
        [self.mobs addObject:[[BDMob alloc] initWithPosition:pointRep.CGPointValue]];
    }
    
    self.hotspots = [NSMutableArray array];
    for (NSDictionary *hotspotDict in primaryStage[@"Hotspots"]) {
        CGRect area = [[[self NSRectsFromArrays:@[hotspotDict[@"Area"]]] lastObject] CGRectValue];
        NSArray *changes = hotspotDict[@"Changes"];
        NSString *level = hotspotDict[@"Level"];
        NSString *stage = hotspotDict[@"Stage"];
        NSDictionary *activeImageInfo = hotspotDict[@"Active"];
        if (activeImageInfo) {
            CGPoint point = CGPointMake([activeImageInfo[@"Origin"][0] floatValue],
                                        [activeImageInfo[@"Origin"][1] floatValue]);
            NSString *imageName = activeImageInfo[@"Image"];
            NSString *soundName = activeImageInfo[@"Sound"];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSValue valueWithCGPoint:point] forKey:@"Origin"];
            if (imageName) [dict setObject:imageName forKey:@"imageName"];
            if (soundName) [dict setObject:soundName forKey:@"Sound"];
            activeImageInfo = dict;
        }
        NSDictionary *inactiveImageInfo = hotspotDict[@"Normal"];
        if (inactiveImageInfo) {
            CGPoint point = CGPointMake([inactiveImageInfo[@"Origin"][0] floatValue],
                                        [inactiveImageInfo[@"Origin"][1] floatValue]);
            NSString *imageName = inactiveImageInfo[@"Image"];
            NSString *soundName = activeImageInfo[@"Sound"];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSValue valueWithCGPoint:point] forKey:@"Origin"];
            if (imageName) [dict setObject:imageName forKey:@"imageName"];
            if (soundName) [dict setObject:soundName forKey:@"Sound"];
            inactiveImageInfo = dict;
        }
        
        self.decals = [self.decals arrayByAddingObject:inactiveImageInfo];
        
        if (changes) {
            BDHotspot *hotspot = [[BDHotspot alloc] initWithFrame:area changes:changes level:self];
            hotspot.toggle = [hotspotDict[@"Repeat"] boolValue];
            hotspot.activeDecal = activeImageInfo;
            hotspot.inactiveDecal = inactiveImageInfo;
            [self.hotspots addObject:hotspot];
        } else if (level) {
            BDHotspot *hotspot = [[BDHotspot alloc] initWithFrame:area levelChange:level level:self];
            hotspot.toggle = [hotspotDict[@"Repeat"] boolValue];
            hotspot.activeDecal = activeImageInfo;
            hotspot.inactiveDecal = inactiveImageInfo;
            [self.hotspots addObject:hotspot];
        } else if (stage) {
            BDHotspot *hotspot = [[BDHotspot alloc] initWithFrame:area stageChange:stage level:self];
            hotspot.toggle = [hotspotDict[@"Repeat"] boolValue];
            hotspot.activeDecal = activeImageInfo;
            hotspot.inactiveDecal = inactiveImageInfo;
            [self.hotspots addObject:hotspot];
        }
    }
    
    [self.delegate level:self didChangeState:self.stage toState:stageName];
    if (updatedPlayerSpawn) {
        [self.delegate level:self didChangePlayerPosition:self.spawn];
    }
    self.stage = stageName;
}

#pragma mark - BDLevelViewDataSource implementation

- (NSArray *)lightsInLevelView:(BDLevelView *)levelView
{
    return self.lights;
}

- (CGFloat)lightScaleInLevelView:(BDLevelView *)levelView
{
    return self.lightScale;
}

@end
