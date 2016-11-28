//
//  NotificationViewController.m
//  YouYunPushContent
//
//  Created by Frederic on 2016/11/21.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>


@interface NotificationViewController () <UNNotificationContentExtension>

@property IBOutlet UILabel *label;

@property (weak, nonatomic) IBOutlet UIImageView *backImageView;


@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any required interface initialization here.
    self.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, 100);
}

- (void)didReceiveNotification:(UNNotification *)notification {
    self.label.text = notification.request.content.body;
    
    UNNotificationAttachment *attach = [notification.request.content.attachments firstObject];
    if (attach.URL.startAccessingSecurityScopedResource) {
        self.backImageView.image = [UIImage imageWithContentsOfFile:attach.URL.path];
    }
    
}

- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption option))completion {
    
    completion(UNNotificationContentExtensionResponseOptionDoNotDismiss);
}

@end
