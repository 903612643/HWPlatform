//
//  IJKAppDelegate.m
//  IJKMediaDemo
//
//  Created by ZhangRui on 13-9-19.
//  Copyright (c) 2013年 bilibili. All rights reserved.
//

#import "IJKAppDelegate.h"
#import "IJKMoviePlayerViewController.h"

@implementation IJKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.viewController = [[IJKVideoViewController alloc] initView];
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    //    PtLoginClass * loginClass = [[PtLoginClass alloc] init];
    //    Boolean rtn = [loginClass CheckLogin:url];
    //    if (rtn == true)
    //    {
    //        NSString * LogResult = @"true";
    //        NSString * UserName = [loginClass GetLoginInfo:url];
    //        self.viewController= (ViewController*)self.window.rootViewController;
    //        self.viewController.routingLabel.text = [NSString stringWithFormat:@"Primary app is login : %@ login UserName&Password: %@", LogResult, UserName];
    //
    //        [self.viewController view];
    //    }
    //    IJKDemoHistoryItem *historyItem = self.historyList[indexPath.row];
    //    [NSString stringWithFormat:@"URL: %@", url];
    
//    NSLog(@"Scheme: %@", [url scheme]);
//    NSLog(@"Host: %@", [url host]);
//    NSLog(@"Path: %@", [url path]);
    NSString * Scheme = @"rtmp://";
    NSString * Host = [url host];
    NSString * Path = [url path];
    
    
    NSString *RTMPPlayURL = [Scheme stringByAppendingString:Host];
    RTMPPlayURL = [RTMPPlayURL stringByAppendingString:Path];;
    NSLog(@"RTMPPlayURL: %@", RTMPPlayURL);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.viewController = [[IJKVideoViewController alloc] initView];
    self.viewController.PlayRtmpURL = RTMPPlayURL;
    self.window.rootViewController = self.viewController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
