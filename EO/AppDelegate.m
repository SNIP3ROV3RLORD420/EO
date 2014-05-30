//
//  AppDelegate.m
//  EO
//
//  Created by Dylan Humphrey on 5/21/14.
//  Copyright (c) 2014 Dylan Humphrey. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "MapViewController.h"
#import "LeftViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation AppDelegate

@synthesize revealSideViewController = _revealSideViewController;

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    //loading parse
    [Parse setApplicationId:@"slWUWmZ3EgTwg2yfLOv0xgUGIY4yLmGQaMvwgWx0"
                  clientKey:@"q8R8J3KzOgH3pGdXsyCmGq0eAQwnTeIDfzZJ52iT"];
    
    [PFFacebookUtils initializeFacebook];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"SpashScreen.png"]];
    
    if ([PFUser currentUser]) {
        
    }
    
    if ([PFUser currentUser] || [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]){
        MapViewController *mv = [[MapViewController alloc]init];
        [[mv view] addSubview:imageView];
        [[mv view] bringSubviewToFront:imageView];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:mv];
        [nav.navigationBar configureFlatNavigationBarWithColor:[UIColor turquoiseColor]];
        
        _revealSideViewController = [[PPRevealSideViewController alloc]initWithRootViewController:nav];
        LeftViewController *lv = [[LeftViewController alloc]init];
        [_revealSideViewController preloadViewController:lv forSide:PPRevealSideDirectionLeft];
    }
    else{
        LoginViewController *lv = [[LoginViewController alloc]init];
        [[lv view] addSubview:imageView];
        [[lv view] bringSubviewToFront:imageView];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:lv];
        [nav.navigationBar configureFlatNavigationBarWithColor:[UIColor turquoiseColor]];
        _revealSideViewController = [[PPRevealSideViewController alloc]initWithRootViewController:nav];
    }
    // as usual
    [self.window makeKeyAndVisible];
    
    //now fade out splash image
    [UIView transitionWithView:self.window duration:1.0f options:UIViewAnimationOptionTransitionNone animations:^(void){imageView.alpha = 0.0f;} completion:^(BOOL finished){[imageView removeFromSuperview];}];
    
    
    _revealSideViewController.options = PPRevealSideOptionsBounceAnimations | PPRevealSideOptionsShowShadows | PPRevealSideOptionsiOS7StatusBarFading;
    
    self.window.rootViewController = _revealSideViewController;
    
    if (PPSystemVersionGreaterOrEqualThan(7.0)) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    }
    
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

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
