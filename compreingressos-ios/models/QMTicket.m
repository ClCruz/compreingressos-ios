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
#import "QMException.h"
#import <PassKit/PassKit.h>
#import <AFNetworking/AFNetworking.h>
#import <Crashlytics/Crashlytics.h>
#import <CommonCrypto/CommonDigest.h>

@implementation QMTicket {
    @private
    NSString *_qrcodeString;
    NSString *_place;
    NSString *_type;
    NSString *_price;
    NSString *_servicePrice;
    NSString *_total;
}

/* Senha utilizada no hash do nome do pkpass */
static char password[] = { 0x51, 0x4d, 0x45, 0x78, 0x63, 0x65, 0x70, 0x74, 0x69, 0x6f, 0x6e, 0x20, 0x2a, 0x65, 0x78, 0x63, 0x65, 0x70, 0x74, 0x69, 0x6f, 0x6e, 0x3b };

@synthesize qrcodeString = _qrcodeString;
@synthesize place        = _place;
@synthesize type         = _type;
@synthesize price        = _price;
@synthesize servicePrice = _servicePrice;
@synthesize total        = _total;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _qrcodeString = [QMRequester objectOrNilForKey:@"qrcode" forDictionary:dictionary];
        _place        = [QMRequester objectOrNilForKey:@"local" forDictionary:dictionary];
        _type         = [QMRequester objectOrNilForKey:@"type" forDictionary:dictionary];
        _price        = [QMRequester objectOrNilForKey:@"price" forDictionary:dictionary];
        _servicePrice = [QMRequester objectOrNilForKey:@"service_price" forDictionary:dictionary];
        _total        = [QMRequester objectOrNilForKey:@"total" forDictionary:dictionary];
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

    if (json) {
        [[Crashlytics sharedInstance] setObjectValue:json forKey:@"Pass JSON"];
        NSData *bodyData = [json dataUsingEncoding:NSUTF8StringEncoding];
        NSString *urlString = [NSString stringWithFormat:@"%@/%@", kMPassbookHost, @"passes/v2/generate.json"];
        NSURL *url = [NSURL URLWithString:[QMRequester addVersionToUrl:urlString]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:bodyData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
        [request setTimeoutInterval:[QMRequester requestTimeout]];
        [request setCachePolicy:[QMRequester cachePolicy]];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *req, NSHTTPURLResponse *response, id JSON) {
            if (JSON) {
                NSString *filename = [self errorMessage];
                NSArray *passes = JSON[@"passes"];
                if ([passes count] > 0) {
                    [self downloadPass:filename];
                } else {
                    [self showDownloadErrorWithTitle:@"Erro POST passbook" andDescription:@"não retornou nenhum file name"];
                }
            } else {
                [self showDownloadErrorWithTitle:@"Erro POST passbook" andDescription:@"não retornou resposta"];
            }
        } failure:^(NSURLRequest *req, NSHTTPURLResponse *response, NSError *error, id JSON) {
            NSLog(@"Erro POST passbook %@", [error description]);
            QMException *exception = [[QMException alloc] initWithNSError:error];
            [exception addPrefixToTitle:@"Erro POST passbook"];
            if (_order.originalJson) exception.moreInfo = _order.originalJson;
            [exception post];
            [SVProgressHUD showErrorWithStatus:@"Não foi possível adicionar ao passbook."];
        }];
        [operation start];
    }
}

/**
* Retorna o nome do pkpass que será baixado no servidor.
* Este nome de método é apenas para fins de obfuscação :P. Deveria se chamar
* getPkpassFilename...
*
* O nome do arquivo é composto pelos 40 primeiros caracteres de
*   SHA256(qrcode + order_number + senha)
* */
- (NSString *)errorMessage {
    NSString *aux = [NSString stringWithCString:password encoding:NSASCIIStringEncoding]; /* pegando a senha */
    NSString *stringIn = [NSString stringWithFormat:@"%@%@%@", _qrcodeString, _order.number, aux];
    NSData *dataIn = [stringIn dataUsingEncoding:NSASCIIStringEncoding];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(dataIn.bytes, dataIn.length,  digest);
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for(int i = 0; i < 40; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    NSString *filename = [NSString stringWithFormat:@"%@.pkpass", [output substringToIndex:40]];
    return filename;
}

- (void)showDownloadErrorWithTitle:(NSString *)title andDescription:(NSString *)description {
    QMException *exception = [[QMException alloc] init];
    exception.title = title;
    exception.desc = description;
    if (_order.originalJson) exception.moreInfo = _order.originalJson;
    [exception post];
    [SVProgressHUD showErrorWithStatus:@"Não foi possível adicionar ao passbook."];
}

- (void)downloadPass:(NSString *)passName {
    NSString *urlString = [NSString stringWithFormat:@"%@/passes/v2/%@", kMPassbookHost, passName];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:[QMRequester requestTimeout]];

    [[Crashlytics sharedInstance] setObjectValue:passName forKey:@"Pass Name"];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id responseObject) {
        NSData *data = (NSData *)responseObject;
        if (data != nil) {
            NSError *error = nil;
            PKPass *pass = [[PKPass alloc] initWithData:data error:&error];
            if (!error) {
                PKAddPassesViewController *controller = [[PKAddPassesViewController alloc] initWithPass:pass];
                @try {
                    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:controller animated:YES completion:^{
                        [SVProgressHUD dismiss];
                    }];
                } @catch (NSException *e) {
                    QMException *exception = [[QMException alloc] initWithNSException:e];
                    if (_order.originalJson) [exception setMoreInfo:_order.originalJson];
                    [exception post];
                    [SVProgressHUD showErrorWithStatus:@"Não foi possível adicionar ao passbook."];
                }
            } else {
                QMException *exception = [[QMException alloc] initWithNSError:error];
                if (_order.originalJson) [exception setMoreInfo:_order.originalJson];
                [exception post];
                [SVProgressHUD showErrorWithStatus:@"Não foi possível adicionar ao passbook."];
            }
        } else {
            QMException *exception = [[QMException alloc] init];
            exception.title = @"Não recebeu nada no downloadPass";
            exception.desc = [NSString stringWithFormat:@"Pass: %@", passName];
            if (_order.originalJson) [exception setMoreInfo:_order.originalJson];
            [exception post];
            [SVProgressHUD showErrorWithStatus:@"Não foi possível adicionar ao passbook."];
        }
    } failure:^(AFHTTPRequestOperation *op, NSError *error) {
        NSLog(@"Error: %@", error);
        QMException *exception = [[QMException alloc] initWithNSError:error];
        [exception addPrefixToTitle:@"Erro no GET passbook"];
        if (_order.originalJson) [exception setMoreInfo:_order.originalJson];
        [exception post];
        [SVProgressHUD showErrorWithStatus:@"Não foi possível adicionar ao passbook."];
    }];
    [operation start];
}

@end
