//
// Created by Robinson Nakamura on 5/26/15.
// Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "QMUser.h"
#import "QMUserRequester.h"
#import "QMConstants.h"

static QMUser *sharedInstance;

@implementation QMUser {

@private
    NSString *_userHash;
    NSString *_phpSession;
    NSString *_email;
    NSString *_password;
}

@synthesize userHash   = _userHash;
@synthesize phpSession = _phpSession;
@synthesize email      = _email;
@synthesize password   = _password;

+ (QMUser *)sharedInstance {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedInstance = [[QMUser alloc] init];
        NSString *userHash   = [[NSUserDefaults standardUserDefaults] objectForKey:@"userHash"];
        NSString *phpSession = [[NSUserDefaults standardUserDefaults] objectForKey:QMUserPhpSession];
        NSString *email      = [[NSUserDefaults standardUserDefaults] objectForKey:QMUserEmail];

        sharedInstance.userHash   = userHash;
        sharedInstance.phpSession = phpSession;
        sharedInstance.email      = email;
//        sharedInstance.userHash = @"%2F1KNTYA%2BTFy0XVbfffL0WJwg5v09aQGisE3EmUgHYrU%3D";
//        sharedInstance.phpSession = @"5tuhmp2o8o02vch75q3o5j4063";
        if (sharedInstance.userHash) {
            [sharedInstance setCrashlyticsInfo];
        }
    });
    return sharedInstance;
}

- (BOOL)hasHash {
    return (_userHash && _userHash.length > 0);
}

- (void)save {
    [self setCrashlyticsInfo];
    [[NSUserDefaults standardUserDefaults] setObject:_userHash   forKey:@"userHash"];
    [[NSUserDefaults standardUserDefaults] setObject:_phpSession forKey:QMUserPhpSession];
    [[NSUserDefaults standardUserDefaults] setObject:_email      forKey:QMUserEmail];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setCrashlyticsInfo {
    if (_userHash) {
        [CrashlyticsKit setObjectValue:_userHash forKey:@"USER"];
    }
    if (_phpSession) {
        [CrashlyticsKit setObjectValue:_phpSession forKey:QMUserPhpSession];
    }
}

- (void)reset {
    _userHash = nil;
    _phpSession = nil;
    _email = nil;
    _password = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userHash"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:QMUserPhpSession];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:QMUserEmail];
    [self deleteCookieWithName:@"user"];
    [self deleteCookieWithName:@"PHPSESSID"];
}

- (void)deleteCookieWithName:(NSString *)name {
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSHTTPCookie *wanted = nil;
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        if ([cookie.name isEqualToString:name]) {
            wanted = cookie;
        }
    }
    if (wanted) {
        [cookieJar deleteCookie:wanted];
    }
}

- (void)loginOnComplete:(void (^)())onCompleteBlock onFail:(void (^)(NSError *error))onFailBlock {
    [SVProgressHUD show];
    [QMUserRequester createSessionWithEmail:_email andPassword:_password onCompleteBlock:^(NSDictionary *session) {
        if (session) {
            _userHash   = session[QMUserHash];
            _phpSession = session[QMUserPhpSession];
            [self save];
            [SVProgressHUD dismiss];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoginTag
                                                                object:self
                                                              userInfo:nil];
            onCompleteBlock();
        } else {
            [SVProgressHUD showErrorWithStatus:@"Email ou senha inválidos"];
            if (onFailBlock) onFailBlock(nil);
        }
    } onFailBlock:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Houve um problema com a conexão. Tente novamente"];
        if (onFailBlock) onFailBlock(error);
    }];
}

- (void)logoutOnComplete:(void (^)())onCompleteBlock onFail:(void (^)(NSError *error))onFailBlock {
    [SVProgressHUD show];
    [QMUserRequester destroySession:_phpSession onCompleteBlock:^{
        [SVProgressHUD dismiss];
        [self reset];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserLogoutTag
                                                            object:self
                                                          userInfo:nil];
        if (onCompleteBlock) onCompleteBlock();
    } onFailBlock:^(NSError *error) {
        [SVProgressHUD dismiss];
        if (onFailBlock) onFailBlock(error);
    }];
}

@end