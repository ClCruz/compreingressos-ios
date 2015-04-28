//
//  QMTicket.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 4/8/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMTicket.h"
#import "QMOrder.h"
#import "QMRequester.h"
#import "SVProgressHUD.h"
#import <PassKit/PassKit.h>
#import <AFNetworking/AFNetworking.h>

@implementation QMTicket {
    @private
    NSString *_qrcodeString;
    NSString *_place;
    NSString *_type;
    NSString *_price;
    NSString *_servicePrice;
    NSString *_total;
    __weak QMOrder  *_order;
}

@synthesize qrcodeString = _qrcodeString;
@synthesize place        = _place;
@synthesize type         = _type;
@synthesize price        = _price;
@synthesize servicePrice = _servicePrice;
@synthesize total        = _total;
@synthesize order        = _order;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _qrcodeString = dictionary[@"qrcode"];
        _place        = dictionary[@"local"];
        _type         = dictionary[@"type"];
        _price        = dictionary[@"price"];
        _servicePrice = dictionary[@"service_price"];
        _total        = dictionary[@"total"];
    }
    return self;
}

- (NSMutableDictionary *)toDictionary {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    if (_qrcodeString) dictionary[@"qrcode"]        = _qrcodeString;
    if (_place)        dictionary[@"local"]         = _place;
    if (_type)         dictionary[@"type"]          = _type;
    if (_price)        dictionary[@"price"]         = _price;
    if (_servicePrice) dictionary[@"service_price"] = _servicePrice;
    if (_total)        dictionary[@"total"]         = _total;
    return dictionary;
}

- (void)addToPassbook {
    [SVProgressHUD show];
    NSString *json = _order.originalJson;
//    json = @"{\"number\":\"436464\",\"date\":\"sáb 28 nov\",\"total\":\"50,00\",\"espetaculo\":{\"titulo\":\"COSI FAN TUT TE 10\",\"endereco\":\"Praça Ramos de Azevedo, s/n - República - São Paulo, SP\",\"nome_teatro\":\"Theatro Municipal de São Paulo\",\"horario\":\"20h00\"},\"ingressos\":[{\"qrcode\":\"0064741128200000100146\",\"local\":\"SETOR 3 ANFITEATRO C-06\",\"type\":\"INTEIRA\",\"price\":\"50,00\",\"service_price\":\" 0,00\",\"total\":\"50,00\"}]}";

    if (json) {
        NSData *bodyData = [json dataUsingEncoding:NSUTF8StringEncoding];
        static NSString *path = @"https://mpassbook.herokuapp.com/passes/generate.json";
        NSURL *url = [NSURL URLWithString:path];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:bodyData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
        [request setTimeoutInterval:[QMRequester requestTimeout]];
        [request setCachePolicy:[QMRequester cachePolicy]];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *req, NSHTTPURLResponse *response, id JSON) {
            /* Vai voltar um array de passes. Porém, não precisamos fazer nada com o retorno
               uma vez que os passes já foram criados no heroku. */
            NSString *passName = [NSString stringWithFormat:@"%@.pkpass", _qrcodeString];
            [self downloadPass:passName];
        } failure:^(NSURLRequest *req, NSHTTPURLResponse *response, NSError *error, id JSON) {
            NSLog(@"Erro POST passbook %@", [error description]);
            [SVProgressHUD showErrorWithStatus:@"Não foi possível adicionar ao passbook."];
        }];
        [operation start];
    }
}

- (void)downloadPass:(NSString *)passName {
    static NSString *format = @"https://mpassbook.herokuapp.com/passes/%@";
    NSString *path = [NSString stringWithFormat:format, passName];
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:[QMRequester requestTimeout]];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", [responseObject class]);
        
        NSData *data = (NSData *)responseObject;
        if (data != nil) {
            NSError *error = nil;
            PKPass *pass = [[PKPass alloc] initWithData:data error:&error];
            PKAddPassesViewController *controller = [[PKAddPassesViewController alloc] initWithPass:pass];
            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:controller animated:YES completion:^{
                [SVProgressHUD dismiss];
            }];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [SVProgressHUD showErrorWithStatus:@"Não foi possível adicionar ao passbook."];
    }];
    [operation start];
}

@end
