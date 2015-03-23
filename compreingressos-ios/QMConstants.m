//
//  QMConstants.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 3/23/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMConstants.h"

@implementation QMConstants

+ (BOOL)isRetina4 {
    return [UIScreen mainScreen].bounds.size.height > kRetina3Height;
}


@end
