//
// Created by Robinson Nakamura on 6/6/14.
// Copyright (c) 2014 Qpro Mobile. All rights reserved.
//

#import <AFNetworking/AFJSONRequestOperation.h>
#import "QMVersionRequester.h"

static NSString *kVersionPath = @"force_update";

@implementation QMVersionRequester {

}

+ (void)requestForceUpdateOnComplete:(void (^)(BOOL))onCompleteBlock
                              onFail:(void (^)(NSError *))onFailBlock {

    NSString *urlString = [self getUrlForPath:kVersionPath];
    NSURL *url = [NSURL URLWithString:urlString];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:[self requestTimeout]];
    [request setCachePolicy:[QMRequester cachePolicy]];

    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSDictionary *json = (NSDictionary *)JSON;
        NSNumber *number = json[@"force_update"];
        BOOL forceUpdate = false;
        if (number) {
            forceUpdate = [number boolValue];
        }
        onCompleteBlock(forceUpdate);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Version - FAIL: %i - %@", (int)error.code, error.domain);
        onFailBlock(error);
    }];
    [operation start];
}
@end