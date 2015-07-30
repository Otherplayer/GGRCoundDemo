//
//  GGRCloudManager.h
//  GGRCloudDemo
//
//  Created by __无邪_ on 15/7/30.
//  Copyright © 2015年 __无邪_. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GGUserInfo.h"

@interface GGRCloudManager : NSObject<RCIMUserInfoDataSource,RCIMConnectionStatusDelegate,RCIMReceiveMessageDelegate>
+ (instancetype)sharedInstance;
/// 获取当前连接状态
@property (nonatomic, assign)BOOL isConnected;
/// 当前用户
@property (nonatomic, strong)GGUserInfo *currentUser;

///初始化用户
- (void)initWithUser:(GGUserInfo *)userInfo;

/// 设置 DeviceToken，用于 APNS 的设备唯一标识。请在调用 connectWithToken 之前调用该方法。
- (void)registerDeviceToken:(NSData *)deviceToken;


/// 连接
- (void)startConnect;
- (void)connect:(void (^)(bool success, NSString *userId))successBlock;

/// Log out。不会接收到push消息。
- (void)logout;

/// 获取未读消息数量
- (int)unreadCount;

///// 刷新未读消息数量
//- (void)refreshUnreadMessage;


/// 推出私信聊天界面
- (void)showInController:(UIViewController *)controller userName:(NSString *)userName targetId:(NSString *)uid;
/// 推出私信对话列表
- (void)gotoConversationListViewController:(UIViewController *)controller;


@end
