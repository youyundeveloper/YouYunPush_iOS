//
//  AppDelegate.m
//  YouYunPushDemo
//
//  Created by Frederic on 2016/11/3.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import <YouYunPush/YouYunPush.h>


NSInteger const kPlatform = YYPushSDKPlatformDevelop;

NSString * const CLIENT_ID = kPlatform == YYPushSDKPlatformOnline ? @"1-20525-4ab3a7c3ddb665945d0074f51e979ef0-ios" : @"1-20142-2e563db99a8ca41df48973b0c43ea50a-ios";
NSString * const SECRET    = kPlatform == YYPushSDKPlatformOnline ? @"6f3efde9fb49a76ff6bfb257f74f4d5b" : @"ace518dab1fde58eacb126df6521d34c";


@interface AppDelegate ()<UNUserNotificationCenterDelegate>


@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // 游云推送初始化
    [YYPush startWithClientID:CLIENT_ID
                       secret:SECRET
                         udid:@"yourUDIDString"
                   UNDelegate:self
                launchOptions:launchOptions
                     platform:kPlatform];
    
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    application.applicationIconBadgeNumber = 0;
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [YYPush registerDeviceToken:deviceToken];
    NSLog(@"device token :%@", token);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [YYPush didReceiveRemoteNotification:userInfo];
    [self scheduleYouYunLocalNotifications:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"YYDidReceiveNotification" object:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"%s:notification:%@", __FUNCTION__, notification);
}

- (void)scheduleYouYunLocalNotifications:(NSDictionary *)userInfo {
    UILocalNotification *localNF = [[UILocalNotification alloc] init];
    localNF.alertBody = [NSString stringWithFormat:@"%@", userInfo[@"aps"][@"alert"]];
    localNF.applicationIconBadgeNumber = [userInfo[@"aps"][@"badge"] integerValue];
    localNF.soundName = UILocalNotificationDefaultSoundName;
    localNF.timeZone = [NSTimeZone defaultTimeZone];
    localNF.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
    localNF.userInfo = userInfo;
    localNF.category = @"category1";
    [[UIApplication sharedApplication] scheduleLocalNotification:localNF];
}

#pragma mark - UNUserNotificationCenterDelegate
// iOS 10 前台收到推送
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        // 远程推送，点击事件统计
        NSDictionary *userInfo = notification.request.content.userInfo;
        [YYPush didReceiveRemoteNotification:userInfo];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"YYWillPresentNotification" object:userInfo];
    }
    
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound);
}
// iOS 10 后台收到推送
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler {
    if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        // 远程推送，点击事件统计
        NSDictionary *userInfo = response.notification.request.content.userInfo;
        [YYPush didReceiveRemoteNotification:userInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"YYDidReceiveNotification" object:userInfo];
    }
    completionHandler();
}

@end
