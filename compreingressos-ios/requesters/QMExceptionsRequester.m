//
// Created by Robinson Nakamura on 6/17/15.
// Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <AFNetworking/AFJSONRequestOperation.h>
#import "QMExceptionsRequester.h"
#import "QMException.h"

static NSString *kExceptionsPath = @"handled_exceptions.json";

@implementation QMExceptionsRequester {

}

/* Overriden */
+ (NSString *)getHost {
    return kCompreIngressoHost;
}

+ (AFJSONRequestOperation *)postExceptionWith:(QMException *)exception
                              onCompleteBlock:(void (^)())onCompleteBlock
                                  onFailBlock:(void (^)(NSError *error))onFailBlock {

    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    NSDictionary *exceptionDictionary = [exception toDictionary];
    jsonDictionary[@"handled_exception"] = exceptionDictionary;

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];

    NSURL *url = [NSURL URLWithString:[self getUrlForPath:kExceptionsPath]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setTimeoutInterval:[self requestTimeout]];
    [request setCachePolicy:[QMRequester cachePolicy]];

    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *req, NSHTTPURLResponse *response, id JSON) {
        if (onCompleteBlock) onCompleteBlock();
    } failure:^(NSURLRequest *req, NSHTTPURLResponse *response, NSError *err, id JSON) {
        if (onFailBlock) onFailBlock(err);
    }];
    [operation start];
    return operation;
}

@end