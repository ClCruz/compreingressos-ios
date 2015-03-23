//
//  QMVisoresRequester.h
//  qprodelivery-ios
//
//  Created by Robinson Nakamura on 12/8/14.
//  Copyright (c) 2014 Qpro Mobile. All rights reserved.
//

#import "QMRequester.h"

@class AFJSONRequestOperation;

@interface QMVisoresRequester : QMRequester

+ (AFJSONRequestOperation *)requestVisoresOnCompleteBlock:(void (^)(NSArray *visores)) onCompleteBlock
                                              onFailBlock:(void (^)(NSError *error)) onFailBlock;


@end
