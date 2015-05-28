//
// Created by Robinson Nakamura on 5/26/15.
// Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QMUser : NSObject

@property(strong, nonatomic) NSString *userHash;

+ (QMUser *)sharedInstance;
- (void)save;

@end