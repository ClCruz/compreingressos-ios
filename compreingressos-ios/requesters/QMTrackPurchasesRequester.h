//
// Created by Robinson Nakamura on 6/22/15.
// Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMRequester.h"

@class QMOrder;
@class AFJSONRequestOperation;



@interface QMTrackPurchasesRequester : QMRequester

+ (AFJSONRequestOperation *)postOrder:(QMOrder *)order
                      onCompleteBlock:(void (^)())onCompleteBlock
                          onFailBlock:(void (^)(NSError *error))onFailBlock;

@end