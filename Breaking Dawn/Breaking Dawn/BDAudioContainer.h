//
//  BDAudioContainer.h
//  Breaking Dawn
//
//  Created by Hendrik Klindworth on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface BDAudioContainer : NSObject

-(id)initWithPath:(NSString *)path count:(int)count;
-(AVAudioPlayer *)getPlayer;

@end
