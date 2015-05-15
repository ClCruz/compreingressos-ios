//
//  QMPushNotificationConfig.m
//  qprodelivery-ios
//
//  Created by Robinson Nakamura on 12/11/14.
//  Copyright (c) 2014 Qpro Mobile. All rights reserved.
//

#import "QMPushNotificationUtils.h"
#import "QMWebViewController.h"
#import <Parse/Parse.h>

QMPushNotificationUtils *sharedInstance;

@implementation QMPushNotificationUtils {
@private
    NSString *_url;
    NSString *_promoCode;
}

@synthesize url = _url;
@synthesize promoCode = _promoCode;

+ (NSString *)parseChannelForDevice {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    NSLog(@"%@", currentInstallation.installationId);
    return [NSString stringWithFormat:@"customer_%@", currentInstallation.installationId];
}

+ (void)handlePush:(NSDictionary *)userInfo {
    NSString *url = userInfo[@"u"];
    NSString *code = userInfo[@"c"];
    if (url) {
        sharedInstance = [[QMPushNotificationUtils alloc] init];
        [sharedInstance setUrl:url];
        [sharedInstance setPromoCode:code];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:userInfo[@"aps"][@"alert"] delegate:sharedInstance cancelButtonTitle:@"Detalhes" otherButtonTitles:@"Fechar", nil];
        [alertView show];
    } else {
        [PFPush handlePush:userInfo];
    }
}

+ (BOOL)subscribedInChannel:(NSString *)channel {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    for (NSString *subscribedChannel in currentInstallation.channels) {
        if ([subscribedChannel isEqualToString:channel]) {
            return YES;
        }
    }
    return NO;
}

+ (void)subscribe:(NSString *)channel {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:channel forKey:@"channels"];
    [currentInstallation saveInBackground];
}

+ (void)unsubscribe:(NSString *)channel {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation removeObject:channel forKey:@"channels"];
    [currentInstallation saveInBackground];
}

+ (void)openWebviewWithURL:(NSString *)url andPromoCode:(NSString *)promoCode {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    QMWebViewController *controller = [storyBoard instantiateViewControllerWithIdentifier:@"QMWebViewController"];
    [controller setUrl:url];
    [controller setPromoCode:promoCode];
    [controller setIsModal:YES];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    NSArray *windows = [[UIApplication sharedApplication] windows];
    UIViewController *homeController = [((UIWindow *)windows[[windows count] - 2]) rootViewController];
    [homeController presentViewController:navigationController animated:YES completion:nil];
    sharedInstance = nil;
}

#pragma mark -
#pragma mark - AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [QMPushNotificationUtils openWebviewWithURL:_url andPromoCode:_promoCode];
    }
}

@end
