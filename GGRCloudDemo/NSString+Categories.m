//
//  NSString+Categories.m
//  GGRongCloud
//
//  Created by __无邪_ on 15/7/30.
//  Copyright © 2015年 __无邪_. All rights reserved.
//

#import "NSString+Categories.h"

@implementation NSString (Categories)
- (NSString *)trimCharacterToToken{
    return [[
             [self
              stringByReplacingOccurrencesOfString:@"<"
              withString:@""]
             stringByReplacingOccurrencesOfString:@">"
             withString:@""]
            stringByReplacingOccurrencesOfString:@" "
            withString:@""];
    
    
}

@end
