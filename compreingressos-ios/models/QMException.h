//
// Created by Robinson Nakamura on 6/17/15.
// Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QMException : NSObject

@property(strong, nonatomic) NSString *title;
@property(strong, nonatomic) NSString *desc;
@property(strong, nonatomic) NSString *stacktrace;
@property(strong, nonatomic) NSString *moreInfo;

- (id)initWithNSException:(NSException *)exception;
- (id)initWithNSError:(NSError *)error;
- (void)addPrefixToTitle:(NSString *)prefix;
- (NSDictionary *)toDictionary;

- (void)post;

@end