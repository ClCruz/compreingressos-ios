//
//  QMOrder.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 4/8/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMOrder.h"
#import "QMEspetaculo.h"
#import "QMTicket.h"

@implementation QMOrder {
    @private
    NSString       *_number;
    NSString       *_date;
    NSString       *_total;
    QMEspetaculo   *_espetaculo;
    NSMutableArray *_tickets;
}

@synthesize number     = _number;
@synthesize date       = _date;
@synthesize total      = _total;
@synthesize espetaculo = _espetaculo;
@synthesize tickets    = _tickets;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _number     = dictionary[@"number"];
        _date       = dictionary[@"date"];
        _total      = dictionary[@"total"];
        _espetaculo = [[QMEspetaculo alloc] initWithDictionary:dictionary[@"espetaculo"]];
        _tickets    = [self parseTickets:dictionary[@"ingressos"]];
    }
    return self;
}

- (NSMutableDictionary *)toDictionary {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    dictionary[@"number"] = _number;
    dictionary[@"date"] = _date;
    dictionary[@"total"] = _total;
    dictionary[@"espetaculo"] = [_espetaculo toDictionary];
    dictionary[@"ingressos"] = [self ticketsDictionaryArray];
    return dictionary;
}

- (NSMutableArray *)parseTickets:(NSArray *)array {
    NSMutableArray *tickets = [[NSMutableArray alloc] init];
    for (NSDictionary *dictionary in array) {
        QMTicket *ticket = [[QMTicket alloc] initWithDictionary:dictionary];
        [tickets addObject:ticket];
    }
    return tickets;
}

- (NSArray *)ticketsDictionaryArray {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (QMTicket *ticket in _tickets) {
        [array addObject:[ticket toDictionary]];
    }
    return array;
}

@end
