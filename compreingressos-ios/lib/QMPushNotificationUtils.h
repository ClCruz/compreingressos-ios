//
//  QMPushNotificationConfig.h
//  qprodelivery-ios
//
//  Created by Robinson Nakamura on 12/11/14.
//  Copyright (c) 2014 Qpro Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMPushNotificationUtils : NSObject <UIAlertViewDelegate>

@property(nonatomic, strong) NSString *url;

+ (NSString *)parseChannelForDevice;
+ (void)handlePush:(NSDictionary *)userInfo;

@end
