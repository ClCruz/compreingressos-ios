//
// Created by Robinson Nakamura on 6/22/15.
// Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMTrackPurchasesRequester.h"
#import "QMOrder.h"
#import "QMException.h"
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

    if (order.numericOrderNumber && order.total) {
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
            } failure:^(NSURLRequest *req, NSHTTPURLResponse *response, NSError *err, id JSON) {
                if (onFailBlock) onFailBlock(err);
            }];
            [operation start];
            return operation;
        } else {
            if (onFailBlock) onFailBlock(error);
            return nil;
        }
    } else {
        QMException *exception = [[QMException alloc] init];
        exception.title = @"Não conseguiu enviar trackPurchases";
        exception.desc  = @"Pedido não possuia número ou valor. Provavelmente deu erro no pedido.";
        NSMutableString *moreInfo = [[NSMutableString alloc] init];
        if (order.numericOrderNumber) {
            [moreInfo appendString:@"numero pedido: "];
            [moreInfo appendString:[order.numericOrderNumber stringValue]];
        }
        if (order.total) {
            [moreInfo appendString:@" total pedidos: "];
            [moreInfo appendString:order.total];
        }
        exception.moreInfo = moreInfo;
        [exception post];
        if (onFailBlock) onFailBlock(nil);
        return nil;
    }
}

@end