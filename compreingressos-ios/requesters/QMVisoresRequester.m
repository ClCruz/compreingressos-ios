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
#import "QMReachability.h"

static NSString *const kVisoresPath = @"visores/lista.json";

@implementation QMVisoresRequester

/* Overriden */
+ (NSString *)getHost {
    return kCompreIngressoHost;
}

+ (AFJSONRequestOperation *)requestVisoresOnCompleteBlock:(void (^)(NSArray *visores)) onCompleteBlock
                                              onFailBlock:(void (^)(NSError *error)) onFailBlock {

    NSString *urlString = [self getUrlForPath:kVisoresPath];
    urlString = [self addQueryStringParamenter:@"con" withValue:[self connectionType] toUrl:urlString];
    urlString = [self addQueryStringParamenter:@"width" withValue:[self resolution] toUrl:urlString];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:5.0];
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

+ (NSString *)resolution {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    int intWidth = (int)fabsf(width);
    return [NSString stringWithFormat:@"%d", intWidth];
}

@end
