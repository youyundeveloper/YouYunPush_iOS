//
//  YYNotificationManage.m
//  YouYunPushDemo
//
//  Created by Frederic on 2016/11/3.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYNotificationManage.h"
#import <YouYunPush/YouYunPush.h>

NSInteger const kPlatform = YYPushSDKPlatformOnline;

NSString * const CLIENT_ID = kPlatform == YYPushSDKPlatformOnline ? @"1-20525-4ab3a7c3ddb665945d0074f51e979ef0-ios" : @"1-20142-2e563db99a8ca41df48973b0c43ea50a-ios";
NSString * const SECRET    = kPlatform == YYPushSDKPlatformOnline ? @"6f3efde9fb49a76ff6bfb257f74f4d5b" : @"ace518dab1fde58eacb126df6521d34c";


@implementation YYNotificationManage


- (void)startNotificationWithOptions:(NSDictionary *)options {
    
}

- (void)registerNotificationCategorys:(NSSet *)categorySet {
    // TODO
    // 暂时不支持交互推送
    [YYPush registerForRemoteNotifications:nil];
}

- (NSString *)registerDeviceToken:(NSData *)deviceToken {
    
    return token;
}

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
}

- (NSString *)getUserID {
    return [YYPush getUserID];
}



@end
