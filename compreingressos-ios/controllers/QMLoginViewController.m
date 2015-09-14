//
//  QMLoginViewController.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 9/11/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import "QMLoginViewController.h"
#import "QMUser.h"
#import "QMConstants.h"
#import "UIButton+WebCache.h"

@interface QMLoginViewController () {
    __weak IBOutlet UITextField *_emailField;
    __weak IBOutlet UITextField *_passwordField;
    __weak IBOutlet UIButton *_loginButton;
}

@end

@implementation QMLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_loginButton setBackgroundColor:UIColorFromRGB(kCompreIngressosDefaultRedColor)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickedOnLoginButton:(id)sender {
    QMUser *user = [QMUser sharedInstance];
    user.email = _emailField.text;
    user.password = _passwordField.text;
    [user loginOnComplete:^{

    } onFail:^(NSError *error) {

    }];
}

@end
