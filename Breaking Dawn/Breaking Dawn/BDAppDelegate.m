//
//  BDAppDelegate.m
//  Breaking Dawn
//
//  Created by Patrick Horlebein on 1/25/13.
//  Copyright (c) 2013 GlobalGameJam. All rights reserved.
//

#import "BDAppDelegate.h"

#import "BDViewController.h"
#import "BDTitleViewController.h"

@implementation BDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"GodMode"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"SkipIntro"];
    
    [[NSUserDefaults standardUserDefaults] setFloat:0.024 forKey:@"AdrenalinLight"];
    [[NSUserDefaults standardUserDefaults] setFloat:0.0068 forKey:@"AdrenalinDusk"];
    [[NSUserDefaults standardUserDefaults] setFloat:0.012 forKey:@"AdrenalinDark"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"PrecitionControlls"];
    [[NSUserDefaults standardUserDefaults] setFloat:2.0 forKey:@"WalkingSpeed"];
    [[NSUserDefaults standardUserDefaults] setFloat:2.5 forKey:@"MobWalkingSpeed"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DebugMenu"];
    [[NSUserDefaults standardUserDefaults] setFloat:1.0/30.0 forKey:@"DrawRate"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"SimultanousMonsterSounds"];
    [[NSUserDefaults standardUserDefaults] setFloat:90.0 forKey:@"DefaultLightRadius"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"RealisticLighting"];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [[NSUserDefaults standardUserDefaults] setFloat:0.65 forKey:@"Scale"];
        self.viewController = [[BDViewController alloc] initWithNibName:@"BDViewController_iPhone" bundle:nil];
    } else {
        [[NSUserDefaults standardUserDefaults] setFloat:1.0 forKey:@"Scale"];
        self.viewController = [[BDViewController alloc] initWithNibName:@"BDViewController_iPad" bundle:nil];
    }
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
