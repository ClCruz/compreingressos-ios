//
// Created by Robinson Nakamura on 5/26/15.
// Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

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
    });
    return sharedInstance;
}

- (BOOL)hasHash {
    return (_userHash && _userHash.length > 0);
}

- (void)save {
    [[NSUserDefaults standardUserDefaults] setObject:_userHash forKey:@"userHash"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end