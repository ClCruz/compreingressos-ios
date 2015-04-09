//
//  QMTicket.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 4/8/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMTicket.h"

@implementation QMTicket {
    @private
    NSString *_qrcodeString;
    NSString *_place;
    NSString *_type;
    NSString *_price;
    NSString *_servicePrice;
    NSString *_total;
}

@synthesize qrcodeString = _qrcodeString;
@synthesize place = _place;
@synthesize type = _type;
@synthesize price = _price;
@synthesize servicePrice = _servicePrice;
@synthesize total = _total;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _qrcodeString = dictionary[@"qrcode"];
        _place = dictionary[@"place"];
        _type = dictionary[@"type"];
        _price = dictionary[@"price"];
        _servicePrice = dictionary[@"service_price"];
        _total = dictionary[@"total"];
    }
    return self;
}

@end
