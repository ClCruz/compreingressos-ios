//
// Created by Robinson Nakamura on 5/26/15.
// Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMRequester.h"

@class QMUser;
@class AFJSONRequestOperation;

@interface QMOrdersRequester : QMRequester

+ (AFJSONRequestOperation *)requestOrdersForUser:(QMUser *)user
                                 onCompleteBlock:(void (^)(NSArray *orders))onCompleteBlock
                                     onFailBlock:(void (^)(NSError *error))onFailBlock;

@end