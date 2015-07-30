//
// Created by Robinson Nakamura on 5/26/15.
// Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "QMUser.h"

static QMUser *sharedInstance;

@implementation QMUser {

@private
    NSString *_userHash;
}

@synthesize userHash = _userHash;

+ (QMUser *)sharedInstance {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedInstance = [[QMUser alloc] init];
        NSString *userHash = [[NSUserDefaults standardUserDefaults] objectForKey:@"userHash"];
        sharedInstance.userHash = userHash;
        // sharedInstance.userHash = @"jRDqK3pUK2%2F1itE7KhxeNIO%2FfS3MCWW2gvIKO9yWywc%3D";
        if (sharedInstance.userHash) {
            [CrashlyticsKit setObjectValue:sharedInstance.userHash forKey:@"USER"];
        }
    });
    return sharedInstance;
}

- (BOOL)hasHash {
    return (_userHash && _userHash.length > 0);
}

- (void)save {
    [CrashlyticsKit setObjectValue:_userHash forKey:@"USER"];
    [[NSUserDefaults standardUserDefaults] setObject:_userHash forKey:@"userHash"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end