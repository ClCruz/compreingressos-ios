//
//  AppDelegate.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 3/16/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "AppDelegate.h"
#import "QMConstants.h"
#import <Google/Analytics.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "NSHTTPCookieStorage+QMStorage.h"
#import "SDImageCache.h"
#import "SVProgressHUD.h"
#import "QMPushNotificationUtils.h"
#import "PFAnalytics.h"
#import "QMVersionRequester.h"
#import <Parse/Parse.h>

@interface AppDelegate () {
    UIAlertView *_forceUpdateView;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initFabric];
    [self initParse:application];
    [self configureNavigationBar];
    [self configureStatusBarColor];
//    if (!kIsDebugBuild) {
    [self configureGoogleAnalytics];
//    }
    [self setupSDImageCache];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.6]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] load];

    /* O payload do push vem por aqui apenas se o app estiver fechado. Neste caso o didReceiveRemoteNotification
     * NÃO é chamado e o payload deve ser recuperado por aqui. */
    NSDictionary *pushPayload = launchOptions[@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    if (pushPayload) {
        [QMPushNotificationUtils handlePush:pushPayload];
    }

    /* Configurando o Analytics do Parse */
    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = !launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }

    return YES;
}

- (void)initFabric {
    [Fabric with:@[CrashlyticsKit]];
    NSString *env = kIsDebugBuild ? @"TEST" : @"PROD";
    [CrashlyticsKit setObjectValue:env forKey:@"ENV"];
}

- (void)initParse:(UIApplication *)application {
    [Parse setApplicationId:@"55QlR3PGrXE0YWWnld97UG7kksTlI6j8ioa0FUIN"
                  clientKey:@"PuVqOzx836qG4Ihv9rcy8kZNtsrU6yxTZJmfe4Uo"];
    
    // Register for Push Notitications
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
}

- (void)configureNavigationBar {
    [[UINavigationBar appearance] setTintColor:UIColorFromRGB(kCompreIngressosDefaultRedColor)];
}

- (void)configureStatusBarColor {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 20)];
    view.backgroundColor = UIColorFromRGB(kCompreIngressosDefaultRedColor);
    [self.window.rootViewController.view addSubview:view];
}

- (void)configureGoogleAnalytics {
    /* Configure tracker from GoogleService-Info.plist. */
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    if (configureError != nil) {
        NSLog(@"Error configuring the Google context: %@", configureError);
    }
    
    /* Optional: configure GAI options. */
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = NO;
    gai.dispatchInterval = 30;
    if (kIsDebugBuild) {
        gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
    }
}

- (void)setupSDImageCache {
    NSString *bundledPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"CustomPathImages"];
    [[SDImageCache sharedImageCache] addReadOnlyCachePath:bundledPath];
    [[SDImageCache sharedImageCache] setMaxCacheSize:50 * 1024 * 1024];
//    [[SDImageCache sharedImageCache] clearDisk];
    //NSLog(@"  max concurrent downloads:: %d", SDWebImageManager.sharedManager.imageDownloader.maxConcurrentDownloads);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    if (![QMPushNotificationUtils subscribedInChannel:@"client"]) {
        [currentInstallation addUniqueObject:@"prospect" forKey:@"channels"];
    }
    if (kIsDebugBuild) {
        [currentInstallation addUniqueObject:@"teste" forKey:@"channels"];
    }
    // [currentInstallation addUniqueObject:@"testeqpro" forKey:@"channels"];
    [currentInstallation saveInBackground];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"%i - %@", (int)error.code, error.description);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    /* Esta callback é chamada apenas se o app estiver aberto ou em background. Se estiver fechado o payload
     * do push deve ser recuperado no didFinishLaunchWithOptions */
    [QMPushNotificationUtils handlePush:userInfo];

    if (application.applicationState == UIApplicationStateInactive) {
        // The application was just brought from the background to the foreground,
        // so we consider the app as having been "opened by a push notification."
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    if (application.applicationState == UIApplicationStateInactive) {
//        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
//    }
//}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (NSString *)forceUpdateMessage {
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleDisplayName"];
    NSString *message = [NSString stringWithFormat:@"Por favor, baixe a versão atualizada do app %@!", appName];
    return message;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidBecomeActiveTag object:nil];
    [QMVersionRequester requestForceUpdateOnComplete:^(BOOL forceUpdate) {
        if (forceUpdate) {
            NSString *message = [self forceUpdateMessage];
            _forceUpdateView = [[UIAlertView alloc] initWithTitle:@""
                                                          message:message
                                                         delegate:self
                                                cancelButtonTitle:@"Atualizar"
                                                otherButtonTitles:nil];
            [_forceUpdateView show];
        }
    }                                         onFail:^(NSError *error) {

    }];
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler {
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){}
    else if ([identifier isEqualToString:@"answerAction"]){}
}
#endif

#pragma mark -
#pragma mark - UIAlertView Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView == _forceUpdateView) {
        [self redirectUserToAppStoreWithTrackId:kTrackId];
    }
}

- (void)redirectUserToAppStoreWithTrackId:(NSString *)trackId {
    NSString *iTunesLink = [NSString stringWithFormat:kAppStoreLink, trackId];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
}

@end
