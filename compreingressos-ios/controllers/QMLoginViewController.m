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
    _emailField.delegate = self;
    _passwordField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickedOnLoginButton:(id)sender {
    if ([self validateFields]) {
        [self doLogin];
    }
}

- (void)doLogin {
    QMUser *user = [QMUser sharedInstance];
    user.email = _emailField.text;
    user.password = _passwordField.text;
    [user loginOnComplete:^{

    } onFail:^(NSError *error) {

    }];
}

- (BOOL)validateFields {

    if (_emailField.text == nil || _emailField.text.length == 0) {
        [self showMessageError:@"Insira um email válido."];
        return NO;
    }

    if (_emailField.text.length > 0 && ![self emailIsValid:_emailField.text]) {
        [self showMessageError:@"Insira um email válido."];
        return NO;
    }

    if (_passwordField == nil || _passwordField.text.length == 0) {
        [self showMessageError:@"Insira uma senha."];
    }

    return YES;
}

- (void)showMessageError:(NSString *)message {
    [SVProgressHUD showErrorWithStatus:message];
}

- (BOOL)emailIsValid:(NSString *)checkString {
    // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 0) { // email
        UIResponder* nextResponder = [textField.superview viewWithTag:1];
        [nextResponder becomeFirstResponder];
    }
    else if (textField.tag == 1) { // senha
        if ([self validateFields]) {
            [self doLogin];
        }
    }
    return NO;
}

@end
