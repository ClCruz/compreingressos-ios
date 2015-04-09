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

- (NSMutableArray *)parseTickets:(NSArray *)array {
    NSMutableArray *tickets = [[NSMutableArray alloc] init];
    for (NSDictionary *dictionary in array) {
        QMTicket *ticket = [[QMTicket alloc] initWithDictionary:dictionary];
        [tickets addObject:ticket];
    }
    return tickets;
}

@end
