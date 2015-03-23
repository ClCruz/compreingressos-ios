//
//  QMVisoresRequester.m
//  qprodelivery-ios
//
//  Created by Robinson Nakamura on 12/8/14.
//  Copyright (c) 2014 Qpro Mobile. All rights reserved.
//

#import "QMVisoresRequester.h"
#import "QMVisor.h"
#import <AFNetworking/AFNetworking.h>

static NSString *const kVisoresPath = @"visores/lista.json";

@implementation QMVisoresRequester

/* Overriden */
+ (NSString *)getHost {
    return kCompreIngressoHost;
}

+ (AFJSONRequestOperation *)requestVisoresOnCompleteBlock:(void (^)(NSArray *visores)) onCompleteBlock
                                              onFailBlock:(void (^)(NSError *error)) onFailBlock {
    
    NSURL *url = [NSURL URLWithString:[self getUrlForPath:kVisoresPath]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:15.0];
    [request setCachePolicy:[QMRequester cachePolicy]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *req, NSHTTPURLResponse *response, id JSON) {
        NSMutableArray *visores = [[NSMutableArray alloc] init];
        NSArray *array = (NSArray *)JSON;
        for (NSDictionary *dictionary in array) {
            QMVisor *visor = [[QMVisor alloc] initWithDictionary:dictionary];
            [visores addObject:visor];
        }
        onCompleteBlock(visores);
    } failure:^(NSURLRequest *req, NSHTTPURLResponse *response, NSError *error, id JSON) {
        onFailBlock(error);
    }];
    [operation start];
    return operation;
}

@end
