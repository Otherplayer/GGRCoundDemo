//
//  GGProgressHUD.m
//  GGProgressHUD
//
//  Created by __无邪_ on 15/5/1.
//  Copyright (c) 2015年 __无邪_. All rights reserved.
//

#import "GGProgressHUD.h"

#define kGGProgressHUDMaskType @"GGProgressHUDMaskType"

#define MB_MULTILINE_TEXTSIZE(text, font, maxSize, mode) [text length] > 0 ? [text \
boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin) \
attributes:@{NSFontAttributeName:font} context:nil].size : CGSizeZero;

@interface GGProgressHUD ()
@property (nonatomic, strong)GGProgressHUD *HUD;
@end



@implementation GGProgressHUD


+ (instancetype)sharedInstance{
    static GGProgressHUD *HUD;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        HUD = [[GGProgressHUD alloc] init];
        HUD.maskType = GGProgressHUDMaskTypeNone;
    });
    return HUD;
}

#pragma mark - Private
/*
 *
 * 激活锁定，点击时可操作
 *
 */
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    GGProgressHUDMaskType maskType = [[[NSUserDefaults standardUserDefaults] objectForKey:kGGProgressHUDMaskType] intValue];
    if (maskType == GGProgressHUDMaskTypeNone) {
        return NO;
    }
    
    return YES;
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    GGProgressHUDMaskType maskType = [[[NSUserDefaults standardUserDefaults] objectForKey:kGGProgressHUDMaskType] intValue];
    if (maskType == GGProgressHUDMaskTypeNone) {
        return nil;
    }
    
    return self;
}
-(void)setMaskType:(GGProgressHUDMaskType)maskType{
    [[NSUserDefaults standardUserDefaults] setInteger:maskType forKey:kGGProgressHUDMaskType];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - Public

+ (instancetype)showTip:(NSString *)text afterDelay:(NSTimeInterval)delay{ //自定义view
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    
    GGProgressHUD *hud = [self showHUDAddedTo:window animated:YES];
    
    // Configure CustomView
    UILabel *backg = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 260, 80)];
    backg.backgroundColor = [UIColor whiteColor];
    backg.textAlignment = NSTextAlignmentCenter;
    backg.textColor = [UIColor darkGrayColor];
    backg.layer.cornerRadius = 10;
    backg.layer.masksToBounds = YES;
    
    NSString *fixText = text?:@"";
    backg.text = fixText;
    
    hud.margin = 0.f;
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = backg;
    hud.dimBackground = NO;
    hud.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.210];
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:delay];
    
    return hud;
    
}

- (void)showTipTextOnly:(NSString *)text dealy:(NSTimeInterval)dealy{ //只有文字的
    [self showTipTextOnly:text dealy:dealy position:GGProgressHUDPosition_center];
}

- (void)showTipTextOnly:(NSString *)text dealy:(NSTimeInterval)dealy position:(GGProgressHUDPosition)position{ //只有文字的
    dispatch_async(dispatch_get_main_queue(), ^{
        self.HUD.mode = MBProgressHUDModeText;
        
        
        NSString *fixText = text?:@"";
        _HUD.detailsLabelText = fixText;
        _HUD.detailsLabelFont = [UIFont systemFontOfSize:15];
        [_HUD setMinSize:CGSizeMake(100, 44)];
        
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        
        switch (position) {
            case GGProgressHUDPosition_top:{
                CGSize detailsLabelSize = MB_MULTILINE_TEXTSIZE(_HUD.detailsLabelText, _HUD.detailsLabelFont, CGSizeMake(screenSize.width - 4 * self.margin,MAXFLOAT), NSLineBreakByWordWrapping);
                CGFloat yoffset = screenSize.height/2 - detailsLabelSize.height / 2 - self.margin * 1.5 - 64;
                [_HUD setYOffset:-yoffset];
            }
                break;
            case GGProgressHUDPosition_bottom:{
                CGSize detailsLabelSize = MB_MULTILINE_TEXTSIZE(_HUD.detailsLabelText, _HUD.detailsLabelFont, CGSizeMake(screenSize.width - 4 * self.margin,MAXFLOAT), NSLineBreakByWordWrapping);
                CGFloat yoffset = screenSize.height/2 - detailsLabelSize.height / 2 - self.margin * 1.5 - 64;
                [_HUD setYOffset:yoffset];
            }
                break;
            default:
                break;
        }
        
        [_HUD show:YES];
        [_HUD hide:YES afterDelay:dealy];
    });
}

- (void)showTipOnView:(UIView *)view tip:(NSString *)text afterDelay:(NSTimeInterval)delay{
    
}

- (void)showProgressWithText:(NSString *)text dealy:(NSTimeInterval)dealy{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.HUD setMode:MBProgressHUDModeIndeterminate];
        NSString *fixText = text?:@"";
        _HUD.detailsLabelText = fixText;
        _HUD.detailsLabelFont = [UIFont systemFontOfSize:15];
        [_HUD show:YES];
        [_HUD hide:YES afterDelay:dealy];
    });
}


#pragma mark - Other

-(MBProgressHUD *)HUD{
    [_HUD removeFromSuperview];
    _HUD = nil;
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    _HUD = [self initWithWindow:window];
    [window addSubview:_HUD];
    
    _HUD.delegate = nil;
    _HUD.margin = 10.f;
    _HUD.dimBackground = NO;
    _HUD.removeFromSuperViewOnHide = YES;
    return _HUD;
}


@end
