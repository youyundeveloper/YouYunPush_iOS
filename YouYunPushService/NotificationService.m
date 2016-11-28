//
//  NotificationService.m
//  YouYunPushService
//
//  Created by Frederic on 2016/11/21.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "NotificationService.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [游云推送]", self.bestAttemptContent.title];
    self.bestAttemptContent.body = [NSString stringWithFormat:@"%@ [游云推送]", self.bestAttemptContent.body];
    
    __weak typeof(self) weakSelf = self;
    [self downloadSaveNotification:request completion:^(NSURL *localURL) {
        NSError *err;
        if (localURL) {
            UNNotificationAttachment *attach = [UNNotificationAttachment attachmentWithIdentifier:@"com.ioyouyun.attachment1" URL:localURL options:nil error:&err];
            if (attach) {
                weakSelf.bestAttemptContent.attachments = @[attach];
            }
        }
        self.contentHandler(self.bestAttemptContent);
    }];
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

- (void)downloadSaveNotification:(UNNotificationRequest *)request completion:(void(^)(NSURL *localURL))handler {
    NSString *sourcePath = request.content.userInfo[@"image"];
    if (!sourcePath) {
        sourcePath = @"http://ww4.sinaimg.cn/large/006tNc79jw1f9g4tij60hj31ki0akadw.jpg";
    }
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:sourcePath] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSString *ext = [sourcePath pathExtension];
            NSURL *catch = [NSURL fileURLWithPath:NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]];
            NSURL *saveURL = [catch URLByAppendingPathComponent:[@"md5String" stringByAppendingPathExtension:ext]];
            [data writeToURL:saveURL atomically:YES];
            if (handler) {
                handler(saveURL);
            }
        }
    }];
    [task resume];
}


@end
