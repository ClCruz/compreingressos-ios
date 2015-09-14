//
// Created by Robinson Nakamura on 9/9/15.
// Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMRequester.h"

@class QMUser;
@class AFHTTPRequestOperation;

static NSString *const QMUserHash = @"user_id";

static NSString *const QMUserPhpSession = @"php_session";

@interface QMUserRequester : QMRequester

+ (AFHTTPRequestOperation *)createSessionWithEmail:(NSString *)email
                                       andPassword:(NSString *)password
                                   onCompleteBlock:(void (^)(NSDictionary *session))onCompleteBlock
                                       onFailBlock:(void (^)(NSError *error))onFailBlock;

+ (AFHTTPRequestOperation *)destroySession:(NSString *)session
                           onCompleteBlock:(void (^)( ))onCompleteBlock
                               onFailBlock:(void (^)(NSError *error))onFailBlock;

@end