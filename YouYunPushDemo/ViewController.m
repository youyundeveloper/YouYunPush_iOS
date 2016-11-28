//
//  ViewController.m
//  YouYunPushDemo
//
//  Created by Frederic on 2016/11/3.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "ViewController.h"
#import <YouYunPush/YouYunPush.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property (weak, nonatomic) IBOutlet UIButton *registerBtn;

@property (weak, nonatomic) IBOutlet UIButton *canclePushBtn;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"游云推送";
    if (![UIApplication sharedApplication].registeredForRemoteNotifications) {
        _canclePushBtn.enabled = NO;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRegisterSucc:) name:YYNotificationsRegisterSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRegisterFailed:) name:YYNotificationsRegisterFailed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willPresentNotification:) name:@"YYWillPresentNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteNotification:) name:@"YYDidReceiveNotification" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerNotification {
    NSSet *set;
    NSString *categaryID = @"category1";
    NSString *action1ID = @"action1";
    NSString *action2ID = @"action2";
    NSString *action3ID = @"action3";
    if ([UIDevice currentDevice].systemVersion.floatValue > 10.0) {
        //iOS10特有
        UNNotificationAction *action1 = [UNNotificationAction actionWithIdentifier:action1ID title:@"确定" options:UNNotificationActionOptionForeground];
        UNNotificationAction *action2 = [UNNotificationAction actionWithIdentifier:action2ID title:@"取消" options:UNNotificationActionOptionDestructive];
        UNNotificationAction *action3 = [UNTextInputNotificationAction actionWithIdentifier:action3ID title:@"反馈" options:UNNotificationActionOptionForeground textInputButtonTitle:@"确定" textInputPlaceholder:@"输入您的反馈意见"];
        UNNotificationCategory *categary = [UNNotificationCategory categoryWithIdentifier:categaryID actions:@[action1,  action2, action3] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
        set = [NSSet setWithObject:categary];
    } else {
        UIMutableUserNotificationCategory *categary = [[UIMutableUserNotificationCategory alloc] init];
        categary.identifier = categaryID;
        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
        action1.title = @"确定";
        action1.identifier = action1ID;
        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];
        action2.title = @"取消";
        action2.identifier = action2ID;
        [categary setActions:@[action1, action2] forContext:UIUserNotificationActionContextDefault];
        set = [NSSet setWithObject:categary];
    }
    [YYPush registerForRemoteNotifications:set];
}

- (IBAction)registerNotifications:(UIButton *)sender {
    BOOL isRegistered = NO;//[UIApplication sharedApplication].registeredForRemoteNotifications;
    NSString *msg = !isRegistered ? @"开启远程推送，及时获得更多内容" : @"已经注册远程推送";
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"征求意见" message:msg preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *confirAct = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (!isRegistered) {
            [weakSelf registerNotification];
        }
    }];
    UIAlertAction *cancleAct = [UIAlertAction actionWithTitle:@"再想想" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:confirAct];
    if (!isRegistered) {
        [alertVC addAction:cancleAct];
    }
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)getRegisterInfo {
    __weak typeof(self) weakSelf = self;
    [YYPush deviceInfoWithCompletionHandler:^(NSDictionary * _Nullable deviceInfo, NSError * _Nullable requestError) {
        if (deviceInfo) {
            [weakSelf appendLogViewText:deviceInfo.description];
        } else {
            [weakSelf appendLogViewText:requestError.localizedDescription];
        }
    }];
}

- (IBAction)cancleBtnAction:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    [YYPush deviceUnRegisterPush:^(BOOL isUnRegister, NSError * _Nullable requestError) {
        NSString *log;
        if (isUnRegister) {
            log = @"取消推送成功";
            [weakSelf getRegisterInfo];
        } else {
            log = [NSString stringWithFormat:@"取消推送失败，Error：%@", requestError];
        }
        [weakSelf appendLogViewText:log];
    }];
}

- (IBAction)setPushTime:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    [YYPush deviceRegisterStartTime:8 endTime:22 completionHandler:^(BOOL isRegister, NSError * _Nullable requestError) {
        if (isRegister) {
            [weakSelf getRegisterInfo];
        } else {
            [weakSelf appendLogViewText:requestError.localizedDescription];
        }
    }];
}

- (void)appendLogViewText:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
       _logTextView.text = [_logTextView.text stringByAppendingFormat:@"\n%@", text];
    });
}

- (void)notificationRegisterSucc:(NSNotification *)notification {
    NSString *userID = [YYPush getUserID];
    [self appendLogViewText:[NSString stringWithFormat:@"游云ID：%@", userID]];
    _registerBtn.enabled = NO;
    [self getRegisterInfo];
}

- (void)notificationRegisterFailed:(NSNotification *)notification {
    [self appendLogViewText:[NSString stringWithFormat:@"授权失败:%@，Error:%@", notification.object, notification.userInfo]];
}

- (void)willPresentNotification:(NSNotification *)notification {
    [self appendLogViewText:[NSString stringWithFormat:@"收到本地推送：%@", notification.object]];
}

- (void)receiveRemoteNotification:(NSNotification *)not {
    [self appendLogViewText:[NSString stringWithFormat:@"收到后台推送：%@", not.object]];
}

@end
