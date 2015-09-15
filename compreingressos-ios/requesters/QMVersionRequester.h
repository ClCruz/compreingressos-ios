//
// Created by Robinson Nakamura on 6/6/14.
// Copyright (c) 2014 Qpro Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMRequester.h"


@interface QMVersionRequester : QMRequester

+ (void)requestForceUpdateOnComplete:(void (^)(BOOL))onCompleteBlock
                              onFail:(void (^)(NSError *))onFailBlock;

@end