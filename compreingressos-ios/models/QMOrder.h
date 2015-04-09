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

@property (strong, nonatomic) NSString *number;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *total;
@property (strong, nonatomic) QMEspetaculo *espetaculo;
@property (strong, nonatomic) NSMutableArray *tickets;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
