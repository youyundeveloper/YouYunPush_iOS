//
//  YYPush.h
//  YouYunPush
//
//  Created by Frederic on 2016/11/2.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  游云推送初始化平台选择
 */
typedef NS_ENUM(NSInteger, YYPushSDKPatform) {
    /**
     *  生产环境
     */
    YYPushSDKPlatformOnline              = 1,
    /**
     *  开发环境
     */
    YYPushSDKPlatformDevelop             = 2,
};

/**
 *  注册游云推送成功、失败结果通知
 */
extern NSString *const YYNotificationsRegisterSuccess;
extern NSString *const YYNotificationsRegisterFailed;


/**
 *  游云推送主体功能
 */
@interface YYPush : NSObject

/**
 *  设置APP启动SDK需要的参数，应用启动参数用来统计用户通过点击通知启动APP
 *
 *  @param client        游云app帐号ID
 *  @param secret        游云app帐号密钥
 *  @param udid          设备标识ID
 *  @param delegate      iOS 10 处理推送对象
 *  @param launchOptions 应用启动参数
 *  @param platform      平台
 *  @return  BOOL   调用参数是否正确，YES：正确
 */
+ (BOOL)startWithClientID:(nullable NSString *)client
                   secret:(nullable NSString *)secret
                     udid:(nullable NSString *)udid
               UNDelegate:(nullable id <UNUserNotificationCenterDelegate>)delegate
            launchOptions:(nullable NSDictionary *)launchOptions
                 platform:(YYPushSDKPatform)platform;

/** 
 *  注册RemoteNotification的类型，默认推送时段0~24
 *  @brief 默认的时候是sound、badge、alert三个功能全部打开, 没有开启交互式推送行为分类。
 *
 *  @param categories 交互式推送行为分类。可以具体查看demo。
 *
 */
+ (void)registerForRemoteNotifications:(nullable NSSet *)categories;

/**
 *  取消UIApplecation注册Notification服务
 *
 *  @see [[UIApplecation sharedApplecation] unregisterForRemoteNotifications]
 */
+ (void)unregisterForRemoteNotifications;

/** 
 *  注册该设备的deviceToken，用于发送Push消息
 *  @param deviceToken APNs返回的deviceToken
 *  @return   设备token字符串或者nil
 */
+ (nullable NSString *)registerDeviceToken:(nullable NSData *)deviceToken;

/**
 *  Called when your app has received a remote notification.
 *  app运行时收到推送, 用来统计
 *
 *  @param userInfo app收到的苹果推送信息
 */
+ (void)didReceiveRemoteNotification:(nullable NSDictionary *)userInfo;

/**
 *  设置设备注册推送时段，需要登录成功后才能有效注册push
 *
 *  @param startTime push时段开始时间(0~24),默认0,  如: 开始时间为9,  结束时间为20, push时段从当天9 点到 当天  20点.
 *  @param endTime   push时段结束时间(0~24),默认24, 如: 开始时间为20, 结束时间为9,  push时段从当天20点到 第二天 9点.
 *  @param handler   回调block (是否操作成功, 如果错误则返回错误信息)
 *
 */
+ (void)deviceRegisterStartTime:(NSInteger)startTime
                        endTime:(NSInteger)endTime
              completionHandler:(void (^)(BOOL isRegister,  NSError* _Nullable requestError))handler;

/**
 *  取消游云平台Notifications服务
 *
 *  @param handler 回调block (设备信息注册信息, 如果错误则返回错误信息)
 */
+ (void)deviceUnRegisterPush:(void (^)(BOOL isUnRegister, NSError* _Nullable requestError))handler;

/**
 *  获取设备Notifications的信息
 *
 *  @param handler 回调block (设备信息注册信息, 如果错误则返回错误信息)
 */
+ (void)deviceInfoWithCompletionHandler:(void (^)(NSDictionary * _Nullable deviceInfo, NSError* _Nullable requestError))handler;

/**
 * 获取游云推送服务器端对应设备的用户ID
 */
+ (nullable NSString *)getUserID;


@end


NS_ASSUME_NONNULL_END

