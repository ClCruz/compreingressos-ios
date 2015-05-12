//
//  NSHTTPCookieStorage+QMStorage.h
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 5/11/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSHTTPCookieStorage (QMStorage)

- (void)save;
- (void)load;

@end
