//
//  BDGameViewController.h
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/25/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDLevel.h"

@interface BDGameViewController : UIViewController<BDLevelDelegate>

- (void)gameWin;

@end
