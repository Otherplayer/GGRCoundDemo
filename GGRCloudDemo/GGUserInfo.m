//
//  GGUserInfo.m
//  GGRCloudDemo
//
//  Created by __无邪_ on 15/7/30.
//  Copyright © 2015年 __无邪_. All rights reserved.
//

#import "GGUserInfo.h"

@implementation GGUserInfo


-(instancetype)initWithUserId:(NSString *)userId name:(NSString *)username portrait:(NSString *)portrait token:(NSString *)token{
    self = [super init];
    if (self) {
        self.userId = userId;
        self.name = username;
        self.portraitUri = portrait;
        self.token = token;
    }
    return self;
}

@end
