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
#import "QMRequester.h"
#import <Foundation/NSJSONSerialization.h>


static QMOrder *instance;
static NSMutableDictionary *orderHistoryInstance;

@implementation QMOrder {
    @private
    NSString       *_number;
    NSString       *_date;
    NSString       *_total;
    NSString       *_originalJson;
    QMEspetaculo   *_espetaculo;
    NSMutableArray *_tickets;
    NSNumber       *_numericOrderNumber; // for sorting
}

@synthesize number             = _number;
@synthesize date               = _date;
@synthesize total              = _total;
@synthesize espetaculo         = _espetaculo;
@synthesize tickets            = _tickets;
@synthesize numericOrderNumber = _numericOrderNumber;
@synthesize originalJson       = _originalJson;

+ (QMOrder *)sharedInstance {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        if (!instance) {
            instance = [[QMOrder alloc] init];
        }
    });
    return instance;
}

+ (NSArray *)orderHistory {
    [self loadHistory];
    return [self sortedHistory];
}

+ (void)loadHistory {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        if (!orderHistoryInstance) {
            orderHistoryInstance = [[NSMutableDictionary alloc] init];
            NSArray *ordersDictArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"orderHistory"];
            if (ordersDictArray) {
                for (NSDictionary *dict in ordersDictArray) {
                    QMOrder *order = [[QMOrder alloc] initWithDictionary:dict];
                    orderHistoryInstance[order.number] = order;
                }
            }
        }
    });
}

+ (NSArray *)sortedHistory {
    NSArray *history = [orderHistoryInstance allValues];
    NSArray *sorted = [self sortOrdersByOrderNumber:history];
    return sorted;
}

+ (void)setOrderHistory:(NSArray *)orders {
    orderHistoryInstance = [[NSMutableDictionary alloc] init];
    for (QMOrder *order in orders) {
        orderHistoryInstance[order.number] = order;
    }
    [self persistOrderHistory];
}

+ (void)addOrderToHistory:(QMOrder *)order {
    if (order.number) {
        [QMOrder orderHistory];
        orderHistoryInstance[order.number] = order;
        [self persistOrderHistory];        
    }
}

+ (NSArray *)sortOrdersByOrderNumber:(NSArray *)orders {
    NSArray *sorted = [orders sortedArrayUsingComparator:^NSComparisonResult(QMOrder *obj1, QMOrder *obj2) {
        if (obj1.numericOrderNumber >= obj2.numericOrderNumber) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    return sorted;
}

+ (void)persistOrderHistory {
    NSMutableArray *ordersDictArray = [[NSMutableArray alloc] initWithCapacity:[orderHistoryInstance count]];
    [orderHistoryInstance enumerateKeysAndObjectsUsingBlock:^(id key, QMOrder *obj, BOOL *stop) {
        [ordersDictArray addObject:[obj toDictionary]];
    }];
    [[NSUserDefaults standardUserDefaults] setObject:ordersDictArray forKey:@"orderHistory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _number       = dictionary[@"number"];
        _date         = dictionary[@"date"];
        _total        = dictionary[@"total"];
        _espetaculo   = [[QMEspetaculo alloc] initWithDictionary:dictionary[@"espetaculo"]];
        _tickets      = [self parseTickets:dictionary[@"ingressos"]];
        _originalJson = [QMRequester objectOrNilForKey:@"originalJson" forDictionary:dictionary];
        
        if (!_originalJson) {
            [self generateOrderJson];
        }
        
        static NSNumberFormatter *formatter = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            formatter = [[NSNumberFormatter alloc] init];
        });
        if (_number ) {
            _numericOrderNumber = [formatter numberFromString:_number];
        }
    }
    return self;
}

- (void)generateOrderJson {
    NSMutableDictionary *dictionary = [self toDictionary];
    [dictionary removeObjectForKey:@"originalJson"];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    _originalJson = json;
}

- (NSMutableDictionary *)toDictionary {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    dictionary[@"number"]       = _number;
    if (_date) dictionary[@"date"]          = _date;
    if (_total) dictionary[@"total"]        = _total;
    dictionary[@"espetaculo"]   = [_espetaculo toDictionary];
    dictionary[@"ingressos"]    = [self ticketsDictionaryArray];
    if (_originalJson) {
        dictionary[@"originalJson"] = _originalJson;
    }
    return dictionary;
}

- (NSMutableArray *)parseTickets:(NSArray *)array {
    NSMutableArray *tickets = [[NSMutableArray alloc] init];
    for (NSDictionary *dictionary in array) {
        QMTicket *ticket = [[QMTicket alloc] initWithDictionary:dictionary];
        [ticket setOrder:self];
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

- (NSString *)formattedOrderNumber {
    return [NSString stringWithFormat:@"Nº #%@", _number];
}

- (NSString *)formattedDateAndHour {
    return [NSString stringWithFormat:@"%@ às %@", _date, _espetaculo.horario];
}

- (NSString *)spectacleTitle {
    return _espetaculo.titulo;
}

@end
