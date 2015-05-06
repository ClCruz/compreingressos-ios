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
#import "QMGenre.h"

@implementation QMEspetaculosRequester {

}

/* Overriden */
+ (NSString *)getHost {
    return kCompreIngressoHost;
}

+ (AFJSONRequestOperation *)requestEspetaculosWithOptions:(NSDictionary *)options onCompleteBlock:(void (^)(NSArray *espetaculos, NSNumber *total))onCompleteBlock onFailBlock:(void (^)(NSError *error))onFailBlock {
    
    NSString *path = kEspetaculosPath;
    if (options && options[@"genero"]) {
        NSString *genre = [self urlEncodeString:options[@"genero"]];
        path = [self addQueryStringParamenter:@"genero" withValue:genre toUrl:path];
    }
    if (options && options[@"cidade"]) {
        NSString *city = [self urlEncodeString:options[@"cidade"]];
        path = [self addQueryStringParamenter:@"cidade" withValue:city toUrl:path];
    }
    if (options && options[@"keywords"]) {
        NSString *keywords = [self urlEncodeString:options[@"keywords"]];
        path = [self addQueryStringParamenter:@"keywords" withValue:keywords toUrl:path];
    }
    if (options && options[@"latitude"] && options[@"longitude"]) {
        NSNumber *lat = options[@"latitude"];
        path = [self addQueryStringParamenter:@"latitude" withValue:[lat stringValue] toUrl:path];
        NSNumber *lng = options[@"longitude"];
        path = [self addQueryStringParamenter:@"longitude" withValue:[lng stringValue] toUrl:path];
    }
    
    NSURL *url = [NSURL URLWithString:[self getUrlForPath:path]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:[self requestTimeout]];
    [request setCachePolicy:[QMRequester cachePolicy]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *req, NSHTTPURLResponse *response, id JSON) {
        NSNumber *total = JSON[@"total"];
        NSArray *array = (NSArray *)JSON[@"espetaculos"];
        NSMutableArray *espetaculos = [[NSMutableArray alloc] init];
        for (NSDictionary *dictionary in array) {
            QMEspetaculo *espetaculo = [[QMEspetaculo alloc] initWithDictionary:dictionary];
            [espetaculos addObject:espetaculo];
        }
        onCompleteBlock(espetaculos, total);
    } failure:^(NSURLRequest *req, NSHTTPURLResponse *response, NSError *error, id JSON) {
        onFailBlock(error);
    }];
    [operation start];
    return operation;
}



@end
