//
//  QMTicket.h
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 4/8/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMTicket : NSObject

@property (strong, nonatomic) NSString *qrcodeString;
@property (strong, nonatomic) NSString *place;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSString *servicePrice;
@property (strong, nonatomic) NSString *total;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSMutableDictionary *)toDictionary;

@end
