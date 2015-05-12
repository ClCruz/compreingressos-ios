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
}

@synthesize url = _url;

+ (NSString *)parseChannelForDevice {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    NSLog(@"%@", currentInstallation.installationId);
    return [NSString stringWithFormat:@"customer_%@", currentInstallation.installationId];
}

+ (void)handlePush:(NSDictionary *)userInfo {
    NSString *url = [userInfo objectForKey:@"uri"];
    if (url) {
        sharedInstance = [[QMPushNotificationUtils alloc] init];
        [sharedInstance setUrl:url];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:userInfo[@"aps"][@"alert"] delegate:sharedInstance cancelButtonTitle:@"Fechar" otherButtonTitles:@"Ver Promoção", nil];
        [alertView show];
    } else {
        [PFPush handlePush:userInfo];
    }
}

#pragma mark -
#pragma mark - AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 0) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        QMWebViewController *controller = [storyBoard instantiateViewControllerWithIdentifier:@"QMWebViewController"];
        [controller setUrl:_url];
        [controller setIsModal:YES];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        NSArray *windows = [[UIApplication sharedApplication] windows];
        UIViewController *homeController = [((UIWindow *)windows[[windows count] - 2]) rootViewController];
        [homeController presentViewController:navigationController animated:YES completion:nil];
        //    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_url]];
        sharedInstance = nil;
    }
}

@end
