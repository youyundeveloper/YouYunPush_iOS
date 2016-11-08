# 游云推送iOS集成文档

## 1. 产品简介

游云推送库帮助您实时的推送消息给用户。

集成之前请在[游云官网](http:www.17youyun.com)填写完整真实信息，新建APP并完善推送资料。新建APP后将获得APP在游云后台服务器对应的`ClientID`和`Secret`。

下载的SDK主要包含以下文件：

- YouYunSDK.framework
- YouYunSDK.framework/YouYunPush
- YouYunSDK.framework/Headers/YouYunPush.h
- YouYunSDK.framework/Headers/YYPush.h
- YouYunSDK.framework/Info.plist
- YouYunSDK.framework/Modules/module.modulemap
- YouYunSDK.framework/README.md

## 2.要求

1. iOS 8.0及以上，SDK是动态库
2. 游云官网的`ClientID`、`Secret`
3. 允许HTTP请求

## 3.基本功能集成

### 1.导入SDK

将`YouYunPush.framework`添加到Xcode的`Targets`目录中，并且添加到`Embedded Binaries`中。如：

![添加SDK](http://ww2.sinaimg.cn/large/006tNc79jw1f9g4m2re0oj31kw106qd5.jpg)

### 2.打开推送开关

在Xcode的`Targets`中的`Capabilities`打开`Push Notifications`。此操作后会自动在工程目录中生成一`*.entitlements`文件，用于推送。如：

![开启Push](http://ww4.sinaimg.cn/large/006tNc79jw1f9g4tij60hj31ki0akadw.jpg)

### 3.允许HTTP请求

由于游云平台目前使用HTTP协议进行通讯，需要开发者允许HTTP请求。

在`*Info.plist`文件中，添加以下代码：

```objective-c
<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSAllowsArbitraryLoads</key>
		<true/>
	</dict>
</key>
```

### 4.添加代码

打开`*AppDelegate.m`文件，依次按以下步骤集成

1. 引入头文件

   ```objective-c
   #import <UserNotifications/UserNotifications.h>
   #import <YouYunPush/YouYunPush.h>
   ```

2. 初始化SDK

   建议在`applecation:didFinishLaunchOptions:`方法中初始化SDK

   ```objective-c
   // 游云推送初始化
   [YYPush startWithClientID:@"游云ClientID"
                      secret:@"游云Secret"
                        udid:@"yourUDIDString"
                  unDelegate:self
               launchOptions:launchOptions
                    platform:kPlatform];
   ```

   其中参数`udid`用来区分设备，需要开发者传入一定规则的非空字符串；参数`unDelegate`用来处理iOS 10新推出的推送。


3.  注册通知

    在需要注册通知的地方注册通知。

    ```objective-c
    [YYPush registerForRemoteNotifications:nil];
    ```

    可以监听游云推送通知获取推送是否注册成功。

    ```objective-c
    /**
     * 成功通知
     */
    extern NSString *const YYNotificationsRegisterSuccess;
    /**
     * 失败通知
     */
    extern NSString *const YYNotificationsRegisterFailed;
    ```

   注意⚠️：

   ​    此方法通用`iOS8.0及以上`系统，由于现在游云后台不支持推送交互，参数传空。

4. 设置Token

   在`*AppDelegate.m`文件中的`applecation:didRegisterForRemoteNotificationsWithDeviceToken:`方法中设置苹果下发的token。

   ```objective-c
   NSString *token = [YYPush registerDeviceToken:deviceToken];
   ```


5. 接收通知

   在iOS 8.0 到iOS 10的系统，用于统计用户对APP在活跃时后台的推送点击：

   ```objective-c
   - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
       
       [YYPush didReceiveRemoteNotification:userInfo];
   }
   ```

   在iOS 10及以上的系统中：

   ```objective-c
   // iOS 10 前台收到推送
   - (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
       if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
           // 远程推送，点击事件统计
           NSDictionary *userInfo = notification.request.content.userInfo;
           [YYPush didReceiveRemoteNotification:userInfo];
       }
       
       completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound);
   }
   // iOS 10 后台收到推送
   - (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler {
       if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
           // 远程推送，点击事件统计
           NSDictionary *userInfo = response.notification.request.content.userInfo;
           [YYPush didReceiveRemoteNotification:userInfo];
       }
       completionHandler();
   }
   ```

至此，消息推送基本功能的集成已经完成。

## 4.其他功能集成

### 1.取消推送

-   取消游云平台的推送

    开发者可以取消设备在游云平台的推送服务，而且保留APP注册推送的功能。

    ```objective-c
    [YYPush deviceUnRegisterPush:^(BOOL isUnRegister, NSError * _Nullable requestError) {
        }];
    ```

    block返回调用接口结果及错误信息。

-   取消APP注册的推送功能。

    ```objective-c
     /**
      *  取消UIApplecation注册Notification服务
      *
      *  @see [[UIApplecation sharedApplecation] unregisterForRemoteNotifications]
      */
     + (void)unregisterForRemoteNotifications;
    ```


### 2.设置推送时段

游云平台提供设置设备推送时段功能

```objective-c
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
```

具体调用：

```objective-c
[YYPush deviceRegisterStartTime:1 endTime:20 completionHandler^(BOOL isRegister,  NSError* _Nullable requestError) {}];
```

### 3.获设备注册推送信息

可以查询设备在游云平台注册的推送时段、设备token

```objective-c
/**
 *  获取设备Notifications的信息
 *
 *  @param handler 回调block (设备信息注册信息, 如果错误则返回错误信息)
 */
+ (void)deviceInfoWithCompletionHandler:(void (^)(NSDictionary *deviceInfo, NSError* _Nullable requestError))handler;
```

### 4.获取设备的ID

可以获取设备在游云平台的ID，可以用于测试推送，此接口必须是成功初始化、注册推送后才能获取到。

```objective-c
/**
 * 获取游云推送服务器端对应设备的用户ID
 */
+ (nullable NSString *)getUserID;
```

