//
//  ViewController.m
//  GGRCloudDemo
//
//  Created by __无邪_ on 15/7/30.
//  Copyright © 2015年 __无邪_. All rights reserved.
//

#import "ViewController.h"
#import "GGRCloudManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






- (IBAction)connectRCloudAction:(id)sender {
    
    if (![[GGRCloudManager sharedInstance] isConnected]) {
        
        [[GGProgressHUD sharedInstance] showProgressWithText:@"正在连接" dealy:40];
        [[GGRCloudManager sharedInstance] connect:^(bool success, NSString *userId) {
            if (success) {
                [[GGRCloudManager sharedInstance] gotoConversationListViewController:self];
                [[GGProgressHUD sharedInstance] showProgressWithText:@"连接成功" dealy:1.2];
            }else{
                [[GGProgressHUD sharedInstance] showProgressWithText:@"连接失败" dealy:1.2];
            }
        }];
    }else{
        [[GGProgressHUD sharedInstance] showTipTextOnly:@"已连接" dealy:1.2];
        [[GGRCloudManager sharedInstance] gotoConversationListViewController:self];
    }
}






@end
