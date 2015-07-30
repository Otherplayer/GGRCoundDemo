//
//  GGRCloudManager.m
//  GGRCloudDemo
//
//  Created by __无邪_ on 15/7/30.
//  Copyright © 2015年 __无邪_. All rights reserved.
//

#import "GGRCloudManager.h"


@interface GGRCloudManager ()

@property (nonatomic, assign) NSInteger isConnecting;

@end

@implementation GGRCloudManager
+ (instancetype)sharedInstance{
    static GGRCloudManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[GGRCloudManager alloc] initConfig];
    });
    return manager;
}

- (instancetype)initConfig
{
    self = [super init];
    if (self) {
        //初始化融云SDK
        [[RCIM sharedRCIM] initWithAppKey:kRongCloudAppKey];
        self.isConnected = NO;
        self.isConnecting = NO;
        
        //设置会话列表头像和会话界面头像
        [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
        if (IS_IPHONE6_PLUS) {
            [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(56, 56);
        } else {
            [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(46, 46);
        }
        
        //设置用户信息源和群组信息源
        [[RCIM sharedRCIM] setUserInfoDataSource:self];
        [[RCIM sharedRCIM] setReceiveMessageDelegate:self];
        [RCIM sharedRCIM].disableMessageNotificaiton = NO;
    }
    return self;
}

- (void)initWithUser:(GGUserInfo *)userInfo{
    self.currentUser = [[GGUserInfo alloc] initWithUserId:userInfo.userId name:userInfo.name portrait:userInfo.portraitUri token:userInfo.token];
}


- (void)registerDeviceToken:(NSData *)deviceToken{
    
    NSString *token = [[deviceToken description] trimCharacterToToken];
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:kDeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
    
    //[self startConnect];
}



- (void)startConnect{
    if (!self.isConnected) {
        [self connect:^(bool success, NSString *userId) {
            if (success) {
                NSLog(@"连接成功");
            }else{
                NSLog(@"连接失败");
            }
        }];
    }
}

- (void)connect:(void (^)(bool success, NSString *userId))successBlock{
    
    /// 连接
    NSString *token        = self.currentUser.token;
    
    if (!token || token.length <= 0 || self.isConnecting) {
        return;
    }
    
    self.isConnecting = YES;
    
    [[RCIM sharedRCIM] connectWithToken:token success:^(NSString *userId) {
        ///连接成功
        
        RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:self.currentUser.userId name:self.currentUser.name portrait:self.currentUser.portraitUri];
        [RCIMClient sharedRCIMClient].currentUserInfo = userInfo;
        [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userId];
        
        
        self.isConnected = YES;
        self.isConnecting = NO;
        
        successBlock(YES, userId);
        
    } error:^(RCConnectErrorCode status) {
        
        self.isConnected = NO;
        self.isConnecting = NO;
        
        successBlock(NO, nil);
        
    } tokenIncorrect:^{
        
        self.isConnected = NO;
        self.isConnecting = NO;
        
        successBlock(NO, nil);
    }];
    
}


- (void)logout{
    [[RCIM sharedRCIM] logout];
    [[RCIM sharedRCIM] disconnect:NO];
}

- (int)unreadCount{
    int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
                                                                         @(ConversationType_PRIVATE),
                                                                         @(ConversationType_DISCUSSION),
                                                                         @(ConversationType_PUBLICSERVICE),
                                                                         @(ConversationType_PUBLICSERVICE),
                                                                         @(ConversationType_GROUP)
                                                                         ]];
    return unreadMsgCount;
}



/// 去对话列表
- (void)showInController:(UIViewController *)controller userName:(NSString *)userName targetId:(NSString *)uid{
    
    
    if (self.isConnected) {
        // 创建单聊视图控制器。
        [self gotoConversationController:controller userName:userName targetId:uid];
    }else{
        //        [HYQShowTip showProgressWithText:@"" dealy:40];
        [self connect:^(bool success, NSString *userId) {
            if (success) {
                //                [HYQShowTip hide:YES];
                [self gotoConversationController:controller userName:userName targetId:uid];
            }else{
                [self showTip:@"连接错误，请稍后重试"];
            }
        }];
    }
    
}




/// 去会话列表
- (void)gotoConversationListViewController:(UIViewController *)controller{
    
    if (self.isConnected) {
        // 创建单聊视图控制器。
        [self gotoConversationListController:controller];
    }else{
        [self connect:^(bool success, NSString *userId) {
            if (success) {
                [self gotoConversationListController:controller];
            }else{
                [self showTip:@"连接错误，请稍后重试"];
            }
        }];
    }
}



///去相应对话框
- (void)gotoConversationListController:(UIViewController *)controller{
    dispatch_async(dispatch_get_main_queue(), ^{
        //        [HYQShowTip hide:YES];
        RCConversationListViewController *sessionVC = [[RCConversationListViewController alloc]init];
        sessionVC.isEnteredToCollectionViewController = YES;
        [controller.navigationController pushViewController:sessionVC animated:YES];
    });
}

- (void)gotoConversationController:(UIViewController *)controller userName:(NSString *)userName targetId:(NSString *)uid{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //        [HYQShowTip hide:YES];
        RCConversationViewController *chatViewController = [[RCConversationViewController alloc] initWithConversationType:ConversationType_PRIVATE targetId:uid];
//        chatViewController.nameStr = @"约吗";
//        chatViewController.currentTarget = uid;
//        chatViewController.currentTargetName = userName;
        [controller setHidesBottomBarWhenPushed: YES];
        [controller.navigationController pushViewController:chatViewController animated:YES];
    });
}






#pragma mark - RCIMUserInfoDataSource

///获取用户信息
- (void)getUserInfoWithUserId:(NSString *)userId
                   completion:(void (^)(RCUserInfo *userInfo))completion{
    NSLog(@"=====%@",userId);
    
    if([userId length] == 0)
        return completion(nil);
    
    RCUserInfo *user = [[RCUserInfo alloc] initWithUserId:userId name:@"otherplayer" portrait:nil];
    return completion(user);
    
    //    [[HYQNetworkManager shareManager] getUserInfoByUserID:userId completion:^(RCUserInfo *user) {
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            return completion(user);
    //        });
    //    }];
    //
    //    return completion(nil);
}


#pragma mark - RCIMConnectionStatusDelegate

/// 监控连接状态
- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status{
    NSLog(@"【RONGYUN Status  %ld，0 is connected success !】",status);
    
    if (status == ConnectionStatus_Connected) {
        self.isConnected = YES;
    }else{
        self.isConnected = NO;
    }
}
///收到信息
- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left{
    NSLog(@"%@   %d",message,left);
    //    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshUnreadNotificationKey object:@([self unreadCount])];
}
///收到本地通知
-(BOOL)onRCIMCustomLocalNotification:(RCMessage*)message withSenderName:(NSString *)senderName{
    [UIApplication sharedApplication].applicationIconBadgeNumber =
    [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
    return NO;
}
-(BOOL)onRCIMCustomAlertSound:(RCMessage*)message{
    return NO;
}
#pragma mark - Private

- (void)showTip:(NSString *)tip{
    [HYQShowTip showTipTextOnly:tip dealy:1.2];
}

@end
