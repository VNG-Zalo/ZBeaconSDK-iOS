//
//  ZAppDelegate.m
//  ZBeaconSDK
//
//  Created by minhtoantm on 11/20/2020.
//  Copyright (c) 2020 minhtoantm. All rights reserved.
//

#import "ZAppDelegate.h"
#import <ZBeaconSDK/ZBeaconSDK.h>
#import <AFNetworkActivityLogger/AFNetworkActivityLogger.h>
#import <UserNotifications/UserNotifications.h>
#import <ZaloSDK/ZaloSDK.h>

#define ZALO_APP_ID @"453673175111169071"

@interface ZAppDelegate() <UNUserNotificationCenterDelegate>

@end

@implementation ZAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    UNAuthorizationOptions options = UNAuthorizationOptionAlert+UNAuthorizationOptionSound;
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        
    }];
    
    [ZBeaconSDK setLogLevel:ZBeaconLogDebug];
    NSLog(@"ZBeaconSDK version: %@", [[ZBeaconSDK sharedInstance] getVersion]);
    
    [[AFNetworkActivityLogger sharedLogger] setLogLevel:AFLoggerLevelInfo];
    [[AFNetworkActivityLogger sharedLogger] startLogging];
    
    [[ZaloSDK sharedInstance] initializeWithAppId:ZALO_APP_ID];
    
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

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [[ZDKApplicationDelegate sharedInstance] application:app
                                                        openURL:url
                                                        options:options];
}

#pragma mark UNUserNotificationCenterDelegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    completionHandler(UNNotificationPresentationOptionAlert);
}

@end
