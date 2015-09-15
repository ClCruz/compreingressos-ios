//
// Created by Robinson Nakamura on 9/15/15.
// Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QMStatesChannelsHistory : NSObject
+ (QMStatesChannelsHistory *)sharedInstance;

- (BOOL)contains:(NSString *)state;

- (void)add:(NSString *)state;
@end