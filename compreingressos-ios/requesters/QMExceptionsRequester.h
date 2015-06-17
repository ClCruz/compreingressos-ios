//
// Created by Robinson Nakamura on 6/17/15.
// Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMRequester.h"

@class QMException;
@class AFJSONRequestOperation;

@interface QMExceptionsRequester : QMRequester

+ (AFJSONRequestOperation *)postExceptionWith:(QMException *)exception
                              onCompleteBlock:(void (^)())onCompleteBlock
                                  onFailBlock:(void (^)(NSError *error))onFailBlock;

@end