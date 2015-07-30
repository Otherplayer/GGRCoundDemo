//
//  GGUserInfo.h
//  GGRCloudDemo
//
//  Created by __无邪_ on 15/7/30.
//  Copyright © 2015年 __无邪_. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

@interface GGUserInfo : RCUserInfo
@property (nonatomic, strong)NSString *token;

-(instancetype)initWithUserId:(NSString *)userId name:(NSString *)username portrait:(NSString *)portrait token:(NSString *)token;

@end
