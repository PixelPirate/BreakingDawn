//
//  BDPostProcessingViewController.h
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/26/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BDLevelView;

@interface BDPostProcessingViewController : UIViewController

@property (strong, readwrite, nonatomic) BDLevelView *currentLevelView;

- (void)static;

@end
