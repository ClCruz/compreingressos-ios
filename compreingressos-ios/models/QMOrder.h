//
//  QMOrder.h
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 4/8/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QMEspetaculo;

@interface QMOrder : NSObject

@property(strong, nonatomic) NSString *number;
@property(strong, nonatomic) NSString *date;
@property(strong, nonatomic) NSString *total;
@property(strong, nonatomic) QMEspetaculo *espetaculo;
@property(strong, nonatomic) NSMutableArray *tickets;
@property(strong, nonatomic) NSNumber *numericOrderNumber;
@property(strong, nonatomic) NSString *originalJson; // json utilizado para criar o pedido

+ (QMOrder *)sharedInstance;
+ (NSArray *)orderHistory;
+ (void)setOrderHistory:(NSArray *)orders;
+ (void)addOrderToHistory:(QMOrder *)order;
+ (NSArray *)sortOrdersByOrderNumber:(NSArray *)orders;
- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSMutableDictionary *)toDictionary;
- (NSString *)formattedDateAndHour;
- (NSString *)formattedOrderNumber;
- (NSString *)spectacleTitle;

- (NSNumber *)numericTotal;
@end
