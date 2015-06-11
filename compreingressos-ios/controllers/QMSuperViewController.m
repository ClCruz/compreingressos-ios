//
// Created by Robinson Nakamura on 6/11/15.
// Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import "QMSuperViewController.h"
#import "QMReachability.h"

@implementation QMSuperViewController {

@private
    UIAlertView *_retryView;
    void (^_retryViewBlock)();
}

@synthesize retryViewBlock = _retryViewBlock;

- (BOOL)isConnected {
    QMReachability *networkReachability = [QMReachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    return networkStatus == ReachableViaWWAN || networkStatus == ReachableViaWiFi;
}

- (UIAlertView *)retryViewWithMessage:(NSString *)message {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Fechar"
                                          otherButtonTitles:@"Tentar Novamente", nil];
    [alert show];
    return alert;
}

- (void)showNotConnectedErrorOnRetry:(void (^)(void))onRetryBlock {
    _retryViewBlock = onRetryBlock;
    _retryView = [self retryViewWithMessage:@"Sem conexão com a internet."];
    [SVProgressHUD dismiss];
}

- (void)showNotConnectedError {
    __weak typeof(self) weakSelf = self;

    void(^retryViewBlock)(void) = ^{
        [weakSelf requestData];
    };

    [self showNotConnectedErrorOnRetry:retryViewBlock];
}

/* To be overriden by subclasses */
- (void)requestData {}

#pragma mark -
#pragma mark - AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == _retryView) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Fechar"]) {
//            [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
        } else {
            _retryViewBlock();
        }
    }
}


@end