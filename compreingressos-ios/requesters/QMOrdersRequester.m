//
// Created by Robinson Nakamura on 5/26/15.
// Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMOrdersRequester.h"
#import "QMOrder.h"
#import <AFNetworking/AFNetworking.h>

static NSString *kOrdersPath = @"";

@implementation QMOrdersRequester {

}

+ (AFJSONRequestOperation *)requestOrdersForUser:(NSString *)userId
                                 onCompleteBlock:(void (^)(NSArray *orders))onCompleteBlock
                                     onFailBlock:(void (^)(NSError *error))onFailBlock {

    NSString *jsonString = @"{ "
            "    \"orders\": [ "
            "        { "
            "            \"number\": \"436447\", "
            "            \"date\": \"sáb 28 nov\", "
            "            \"total\": \"50,00\", "
            "            \"espetaculo\": { "
            "                \"titulo\": \"COSI FAN TUT TE\", "
            "                \"endereco\": \"Praça Ramos de Azevedo, s/n - República - São Paulo, SP\", "
            "                \"nome_teatro\": \"Theatro Municipal de São Paulo\", "
            "                \"horario\": \"20h00\" "
            "            }, "
            "            \"ingressos\": [ "
            "                { "
            "                    \"qrcode\": \"0054721128200000100986\", "
            "                    \"local\": \"SETOR 3 BALCÃO SIMPLES D-44\", "
            "                    \"type\": \"INTEIRA\", "
            "                    \"price\": \"50,00\", "
            "                    \"service_price\": \" 0,00\", "
            "                    \"total\": \"50,00\" "
            "                } "
            "            ] "
            "        }, "
            "        { "
            "            \"number\": \"436448\", "
            "            \"date\": \"sáb 29 nov\", "
            "            \"total\": \"51,00\", "
            "            \"espetaculo\": { "
            "                \"titulo\": \"COSI FAN TUT TE 2\", "
            "                \"endereco\": \"Praça Ramos de Azevedo, s/n - República - São Paulo, SP\", "
            "                \"nome_teatro\": \"Theatro Municipal de São Paulo\", "
            "                \"horario\": \"21h00\" "
            "            }, "
            "            \"ingressos\": [ "
            "                { "
            "                    \"qrcode\": \"0054721128200000100534\", "
            "                    \"local\": \"SETOR 3 BALCÃO SIMPLES D-45\", "
            "                    \"type\": \"INTEIRA\", "
            "                    \"price\": \"51,00\", "
            "                    \"service_price\": \" 0,00\", "
            "                    \"total\": \"51,00\" "
            "                } "
            "            ] "
            "        } "
            "    ] "
            "} ";

    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSArray *orders = [self parseOrderFromJson:jsonDictionary];
    onCompleteBlock(orders);
    return nil;

    NSURL *url = [NSURL URLWithString:[self getUrlForPath:kOrdersPath]];
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
    NSArray *array = (NSArray *)json[@"orders"];
    NSMutableArray *orders = [[NSMutableArray alloc] init];
    for (NSDictionary *dictionary in array) {
        QMOrder *order = [[QMOrder alloc] initWithDictionary:dictionary];
        [orders addObject:order];
    }
    return orders;
}

@end