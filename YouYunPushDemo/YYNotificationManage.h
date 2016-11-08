//
//  YYNotificationManage.h
//  YouYunPushDemo
//
//  Created by Frederic on 2016/11/3.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

extern NSString *const YYNotificationsRegisterSuccess;

@interface YYNotificationManage : NSObject<UNUserNotificationCenterDelegate>

- (void)startNotificationWithOptions:(NSDictionary *)options;

- (void)registerNotificationCategorys:(NSSet *)categorySet;

- (NSString *)registerDeviceToken:(NSData *)deviceToken;

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;

- (NSString *)getUserID;

@end
