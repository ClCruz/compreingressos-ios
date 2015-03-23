//
//  QMEspetaculosRequester.m
//  qprodelivery-ios
//
//  Created by Robinson Nakamura on 12/4/14.
//  Copyright (c) 2014 Qpro Mobile. All rights reserved.
//

static NSString *const kEspetaculosPath = @"espetaculos.json";

#import "QMEspetaculosRequester.h"
#import "QMEspetaculo.h"
#import <AFNetworking/AFNetworking.h>

@implementation QMEspetaculosRequester {

}

/* Overriden */
+ (NSString *)getHost {
    return kCompreIngressoHost;
}

+ (AFJSONRequestOperation *)requestEspetaculosWithOptions:(NSDictionary *)options
                           onCompleteBlock:(void (^)(NSArray *espetaculos)) onCompleteBlock
                               onFailBlock:(void (^)(NSError *error)) onFailBlock {
    
    NSString *path = kEspetaculosPath;
    if (options && options[@"genre"]) {
        path = [self addQueryStringParamenter:@"genero" withValue:options[@"genero"] toUrl:path];
    }
    if (options && options[@"cidade"]) {
        NSString *urlEncoded = [self urlEncodeString:options[@"cidade"]];
        path = [self addQueryStringParamenter:@"cidade" withValue:urlEncoded toUrl:path];
    }
    if (options && options[@"busca"]) {
        path = [self addQueryStringParamenter:@"busca" withValue:options[@"busca"] toUrl:path];
    }
    
    NSURL *url = [NSURL URLWithString:[self getUrlForPath:path]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:[self requestTimeout]];
    [request setCachePolicy:[QMRequester cachePolicy]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *req, NSHTTPURLResponse *response, id JSON) {
        NSMutableArray *espetaculos = [[NSMutableArray alloc] init];
        NSArray *array = (NSArray *)JSON;
        for (NSDictionary *dictionary in array) {
            QMEspetaculo *espetaculo = [[QMEspetaculo alloc] initWithDictionary:dictionary];
            [espetaculos addObject:espetaculo];
        }
        onCompleteBlock(espetaculos);
    } failure:^(NSURLRequest *req, NSHTTPURLResponse *response, NSError *error, id JSON) {
        onFailBlock(error);
    }];
    [operation start];
    return operation;
}

@end
