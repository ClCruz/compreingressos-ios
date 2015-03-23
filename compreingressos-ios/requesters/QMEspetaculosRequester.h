//
//  QMEspetaculosRequester.h
//  qprodelivery-ios
//
//  Created by Robinson Nakamura on 12/4/14.
//  Copyright (c) 2014 Qpro Mobile. All rights reserved.
//

#import "QMRequester.h"

@class AFJSONRequestOperation;

@interface QMEspetaculosRequester : QMRequester

+ (AFJSONRequestOperation *)requestEspetaculosWithOptions:(NSDictionary *)options
                                          onCompleteBlock:(void (^)(NSArray *espetaculos)) onCompleteBlock
                                              onFailBlock:(void (^)(NSError *error)) onFailBlock;

@end
