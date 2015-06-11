//
// Created by Robinson Nakamura on 6/11/15.
// Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMSuperViewController : UIViewController <UIAlertViewDelegate> {

}

@property (nonatomic, copy) void (^retryViewBlock)(void);

- (BOOL)isConnected;
- (void)showNotConnectedError;
- (void)showNotConnectedErrorOnRetry:(void (^)(void))onRetryBlock;
- (void)requestData;

@end