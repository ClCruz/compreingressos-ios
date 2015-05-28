//
// Created by Robinson Nakamura on 5/26/15.
// Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMOrdersRequester.h"
#import "QMOrder.h"
#import "QMUser.h"
#import <AFNetworking/AFNetworking.h>

static NSString *kOrdersPath = @"tickets.json";

@implementation QMOrdersRequester {

}

/* Overriden */
+ (NSString *)getHost {
    return kCompreIngressoHost;
}

+ (AFJSONRequestOperation *)requestOrdersForUser:(QMUser *)user
                                 onCompleteBlock:(void (^)(NSArray *orders))onCompleteBlock
                                     onFailBlock:(void (^)(NSError *error))onFailBlock {

    NSString *urlString = [self getUrlForPath:kOrdersPath];
    urlString = [self addQueryStringParamenter:@"client_id" withValue:user.userHash toUrl:urlString];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:[self requestTimeout]];
    [request setCachePolicy:[QMRequester cachePolicy]];

    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *req, NSHTTPURLResponse *response, id JSON) {
        NSArray *orders = [self parseOrderFromJson:JSON];
        onCompleteBlock(orders);
    } failure:^(NSURLRequest *req, NSHTTPURLResponse *response, NSError *error, id JSON) {
        onFailBlock(error);
    }];
    [operation start];
    return operation;
}

+ (NSArray *)parseOrderFromJson:(id )json {
    NSArray *array = (NSArray *)json;
    NSMutableArray *orders = [[NSMutableArray alloc] init];
    for (NSDictionary *dictionary in array) {
        QMOrder *order = [[QMOrder alloc] initWithDictionary:dictionary];
        [orders addObject:order];
    }
    return orders;
}

@end