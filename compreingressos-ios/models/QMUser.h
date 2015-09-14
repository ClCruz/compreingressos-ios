//
// Created by Robinson Nakamura on 5/26/15.
// Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>


static NSString *const QMUserEmail = @"email";

@interface QMUser : NSObject

@property(strong, nonatomic) NSString *userHash;
@property(strong, nonatomic) NSString *phpSession;   // utilizado nos cookies da compreingresssos
@property(strong, nonatomic) NSString *email;
@property(strong, nonatomic) NSString *password;

+ (QMUser *)sharedInstance;
- (void)save;
- (BOOL)hasHash;
- (void)loginOnComplete:(void (^)())onCompleteBlock onFail:(void (^)(NSError *error))onFailBlock;
- (void)logoutOnComplete:(void (^)())onCompleteBlock onFail:(void (^)(NSError *error))onFailBlock;

@end