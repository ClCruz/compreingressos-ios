//
// Created by Robinson Nakamura on 9/9/15.
// Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMUserRequester.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFHTTPRequestOperation.h>

static NSString *kSessionsPath = @"sessions";

@implementation QMUserRequester {

}

+ (AFHTTPRequestOperation *)createSessionWithEmail:(NSString *)email
                                       andPassword:(NSString *)password
                                   onCompleteBlock:(void (^)(NSDictionary *session))onCompleteBlock
                                       onFailBlock:(void (^)(NSError *error))onFailBlock {

    NSString *urlString = [self getUrlForPath:kSessionsPath];
    NSURL *url = [NSURL URLWithString:urlString];
    NSDictionary *json = @{
        @"email": email,
        @"password": password
    };

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];

    if (!error) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:jsonData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
        [request setTimeoutInterval:[self requestTimeout]];
        [request setCachePolicy:[QMRequester cachePolicy]];

        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *req, NSHTTPURLResponse *response, id JSON) {
            NSString *userId = JSON[QMUserHash];
            NSString *phpSession = JSON[QMUserPhpSession];
            onCompleteBlock(@{QMUserHash : userId, QMUserPhpSession : phpSession});
        } failure:^(NSURLRequest *req, NSHTTPURLResponse *response, NSError *error, id JSON) {
            if (response.statusCode == 422) {
                /* credenciais inválidas */
                onCompleteBlock(nil);
            } else {
                onFailBlock(error);
            }
        }];
        [operation start];
        return operation;
    } else {
        return nil;
    }
}

+ (AFHTTPRequestOperation *)destroySession:(NSString *)session
                           onCompleteBlock:(void (^)( ))onCompleteBlock
                               onFailBlock:(void (^)(NSError *error))onFailBlock {

    NSString *path = [NSString stringWithFormat:@"%@/%@", kSessionsPath, session];
    NSString *urlString = [self getUrlForPath:path];
    NSURL *url = [NSURL URLWithString:urlString];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"DELETE"];
    [request setTimeoutInterval:[self requestTimeout]];
    [request setCachePolicy:[QMRequester cachePolicy]];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id responseObject) {
        if(onCompleteBlock) onCompleteBlock();
    } failure:^(AFHTTPRequestOperation *op, NSError *error) {
        if(onFailBlock) onFailBlock(error);
    }];
    [operation start];
    return operation;
}

@end