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

//- (void)loadLightmap;

@end


@implementation BDLevel

- (id)initWithName:(NSString *)name
{/*
    self = [super init];
    if (self) {
        self.diffuseMap = [UIImage imageNamed:[name stringByAppendingString:@"_diffuse"]];
        UIImage *collision = [UIImage imageNamed:[name stringByAppendingString:@"_collision"]];
        self.collisionMap = [[BDImageMap alloc] initWithUIImage:collision];
        
        self.lights = [NSMutableArray array];
        NSURL *url = [[[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:@"map00.plist"] filePathURL];
        NSDictionary *mapInfos = [NSDictionary dictionaryWithContentsOfURL:url];
        
        NSArray *pointLights = [self valuesWithPositions:mapInfos[@"Stages"][0][@"Lights"]];
        [self.lights addObjectsFromArray:pointLights];
        
        // Load lightmap from file or generate it if file is missing
//        UIImage *light = [UIImage imageNamed:[name stringByAppendingString:@"_light"]];
//        if (light) {
//            self.lightMap = [[BDImageMap alloc] initWithUIImage:light];
//        } else {
//            [self loadLightmap];
//        }
        
        self.lightScale = 1.0;
        
        self.mobs = [NSMutableArray array];
        [self.mobs addObject:[[BDMob alloc] initWithPosition:CGPointMake(300, 350)]];
        NSArray *mobSpawns = [self valuesWithPositions:mapInfos[@"Stages"][0][@"Monsters"]];
        for (NSValue *pointRep in mobSpawns) {
            CGPoint position = pointRep.CGPointValue;
            [self.mobs addObject:[[BDMob alloc] initWithPosition:position]];
        }
        
        CGSize imageSize = self.diffuseMap.size;
        
        CGPoint spawn = CGPointZero;
        spawn = [[self valueWithPositionDictionary:mapInfos[@"Stages"][0][@"Spawn"]] CGPointValue];
        self.spawn = spawn;
        
        self.size = imageSize;
        
        self.hotspots = [NSMutableArray array];
        [self.hotspots addObject:[[BDHotspot alloc] initWithFrame:CGRectMake(1196, 663, 80, 60) trigger:^{
            [[BDSound sharedSound] playSound:SOUND_LIGHT_SWITCH];
            // The model (BDLevel) notifies it's view (BDLevelView) that the data has been changed and the view shoud refresh itselve.
            NSArray *pointLights = [self valuesWithPositions:mapInfos[@"Stages"][1][@"Lights"]];
            //self.lightSwitchVisible = NO;
            [self.delegate level:self didAddLights:pointLights];
            [self.lights addObjectsFromArray:pointLights];
        }]];
        
        [self.hotspots addObject:[[BDHotspot alloc] initWithFrame:CGRectMake(50, 705, 80, 100) trigger:^{
            [self.delegate levelWillWin:self];
        }]];
        
        //self.lightSwitchVisible = YES;
    }
    return self;*/
}

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

- (id)initWithContentsOfFileNamed:(NSString *)fileName
{
    self = [super init];
    if (self) {
        NSURL *mapURL = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:fileName];
        NSError *error = nil;
        NSDictionary *levelInfo = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:mapURL] options:0 error:&error];
        if (error) {
            NSLog(@"<Warning> Could not load level %@, %@", fileName, error);
            return nil;
        }
        
        NSString *backgroundImageName = levelInfo[@"Background"];
        NSString *collisionImageName = levelInfo[@"Collision"];
        
        NSDictionary *primaryStage = levelInfo[@"0"];
        NSArray *lightPositions = [self NSPointsFromArrays:primaryStage[@"Lights"]];
        NSArray *trapLights = primaryStage[@"TrapLights"];
        NSArray *timedLights = primaryStage[@"TimedLights"];
        NSArray *mobPositions = [self NSPointsFromArrays:primaryStage[@"MobSpawns"]];
        CGPoint playerSpawn = CGPointMake([primaryStage[@"Spawn"][0] floatValue], [primaryStage[@"Spawn"][1] floatValue]);
        
        self.diffuseMap = [UIImage imageNamed:backgroundImageName];
        UIImage *collision = [UIImage imageNamed:collisionImageName];
        self.collisionMap = [[BDImageMap alloc] initWithUIImage:collision];
        
        self.lights = [NSMutableArray arrayWithArray:lightPositions];
        self.trapLights = [NSMutableArray array];
        for (NSDictionary *trapLightInfo in trapLights) {
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:trapLightInfo];
            [dictionary setObject:[NSNumber numberWithBool:NO] forKey:@"Triggered"];
            [self.trapLights addObject:dictionary];
        }
        for (NSDictionary *trapLightInfo in self.trapLights) {
            NSValue *trapLight = [[self NSPointsFromArrays:@[trapLightInfo[@"Position"]]] lastObject];
            [self.lights addObject:trapLight];
        }
        self.timedLights = [NSMutableArray array];
        for (NSDictionary *timedLightInfo in timedLights) {
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:timedLightInfo];
            [dictionary setObject:[NSNumber numberWithBool:NO] forKey:@""];
            NSValue *position = [[self NSPointsFromArrays:@[timedLightInfo[@"Position"]]] lastObject];
            [dictionary setObject:position forKey:@"Position"];
            [dictionary setObject:[NSNumber numberWithBool:NO] forKey:@"Appearing"];
            [dictionary setObject:timedLightInfo[@"Reappear"] forKey:@"ReappearingDate"];
            [dictionary setObject:timedLightInfo[@"Disappear"] forKey:@"DisappearingDate"];
            
            [self.timedLights addObject:dictionary];
            [self.lights addObject:position];
        }
        
        self.lightScale = 1.0;
        
        self.mobs = [NSMutableArray array];
        for (NSValue *pointRep in mobPositions) {
            [self.mobs addObject:[[BDMob alloc] initWithPosition:pointRep.CGPointValue]];
        }
        
        CGSize imageSize = self.diffuseMap.size;
        
        self.spawn = playerSpawn;
        
        self.size = imageSize;
        
        self.decals = [NSArray array];
        
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
    BDLevel *level = [[BDLevel alloc] initWithName:name];
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
        
        if([self isLineFrom:from to:to withinRadius:fakeRadius fromPoint:lightPosition]) return NO;
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
    BOOL(^CircleContainsPoint)(CGPoint center, CGFloat radius, CGPoint p) = ^(CGPoint center, CGFloat radius, CGPoint p) {
        if ((pow(p.x-center.x, 2.0) + pow(p.y - center.y, 2.0)) < pow(radius, 2.0)) {
            return YES;
        } else {
            return NO;
        }
    };
    
    // Trap lights
    CGFloat radius = 80.0 * self.lightScale;
    for (NSMutableDictionary *trapLightInfo in self.trapLights) {
        NSValue *center = [[self NSPointsFromArrays:@[trapLightInfo[@"Position"]]] lastObject];
        BOOL triggered = [trapLightInfo[@"Triggered"] boolValue];
        
        if (CircleContainsPoint(center.CGPointValue, radius, position) && !triggered) {
            NSTimeInterval duration = [trapLightInfo[@"Duration"] doubleValue];
            NSTimeInterval reappear = [trapLightInfo[@"Reappear"] doubleValue];
            [trapLightInfo setObject:[NSNumber numberWithBool:YES] forKey:@"Triggered"];
            
            int64_t delayInMilliseconds = duration * 1000.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInMilliseconds * NSEC_PER_MSEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self.lights removeObject:center];
                [[BDSound sharedSound] playSound:SOUND_LIGHT_EXPLODE];
            });
            
            if (reappear <= 0.0) {
                [self.trapLights removeObject:trapLightInfo];
            } else {
                int64_t delayInMilliseconds = reappear * 1000.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInMilliseconds * NSEC_PER_MSEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [trapLightInfo setObject:[NSNumber numberWithBool:NO] forKey:@"Triggered"];
                    [self.lights addObject:center];
                });
            }
        }
    }
    
    // Timed lights
    NSTimeInterval duration = [self.levelStartingDate timeIntervalSinceNow]; // Negative since starting time is in the past.
    for (NSMutableDictionary *timedLightInfo in self.timedLights) {
        NSValue *center = timedLightInfo[@"Position"];
        CGFloat disappear = [timedLightInfo[@"Disappear"] floatValue];
        CGFloat reappear = [timedLightInfo[@"Reappear"] floatValue];
        CFAbsoluteTime reappearingDate = [timedLightInfo[@"ReappearingDate"] doubleValue];
        CFAbsoluteTime disappearingDate = [timedLightInfo[@"DisappearingDate"] doubleValue];
        
        BOOL appearing = [timedLightInfo[@"Appearing"] boolValue];
        
        if (!appearing) {
            if ((- duration) > disappearingDate) {
                [[BDSound sharedSound] playSound:SOUND_LIGHT_EXPLODE];
                [self.lights removeObject:center];
                
                [timedLightInfo setObject:[NSNumber numberWithBool:YES] forKey:@"Appearing"];
                if (reappear > 0.0) [timedLightInfo setObject:[NSNumber numberWithDouble:reappear + (-duration)]
                                                       forKey:@"ReappearingDate"];
                if (reappear <= 0.0) {
                    [self.timedLights removeObject:timedLightInfo];
                }
            }
        } else {
            if ((-duration) > reappearingDate) {
                [timedLightInfo setObject:[NSNumber numberWithDouble:disappear + (-duration)] forKey:@"DisappearingDate"];
                [timedLightInfo setObject:[NSNumber numberWithBool:NO] forKey:@"Appearing"];
                [self.lights addObject:center];
            }
        }
    }
}

- (void)levelDidBegin
{
    self.levelStartingDate = [NSDate date];
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
/*
- (BOOL)lightSwitchIsVisibleInLevelView:(BDLevelView *)levelView
{
    return self.lightSwitchVisible;
}
*/
@end
