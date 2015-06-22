//
// Created by Robinson Nakamura on 6/22/15.
// Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMTrackPurchasesRequester.h"
#import "QMOrder.h"
#import <AFNetworking/AFNetworking.h>

static NSString *const kTrackPurchasesPath = @"track_purchases.json";

@implementation QMTrackPurchasesRequester {

}

/* Overriden */
+ (NSString *)getHost {
    return kCompreIngressoHost;
}

+ (AFJSONRequestOperation *)postOrder:(QMOrder *)order
                      onCompleteBlock:(void (^)())onCompleteBlock
                          onFailBlock:(void (^)(NSError *error))onFailBlock {

    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    jsonDictionary[@"number"] = order.numericOrderNumber;
    jsonDictionary[@"total"]  = order.total;

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];

    if (!error) {
        NSString *path = kTrackPurchasesPath;
        NSURL *url = [NSURL URLWithString:[self getUrlForPath:path]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:jsonData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
        [request setTimeoutInterval:[self requestTimeout]];
        [request setCachePolicy:[QMRequester cachePolicy]];

        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *req, NSHTTPURLResponse *response, id JSON) {
            if (onCompleteBlock) onCompleteBlock();
        } failure:^(NSURLRequest *req, NSHTTPURLResponse *response, NSError *error, id JSON) {
            if (onFailBlock) onFailBlock(error);
        }];
        [operation start];
        return operation;
    } else {
        if (onFailBlock) onFailBlock(error);
        return nil;
    }
}

@end