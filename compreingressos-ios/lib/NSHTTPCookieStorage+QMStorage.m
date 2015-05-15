//
//  NSHTTPCookieStorage+QMStorage.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 5/11/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "NSHTTPCookieStorage+QMStorage.h"

@implementation NSHTTPCookieStorage (QMStorage)

- (void)save {
    NSMutableArray *cookieArray = [[NSMutableArray alloc] init];
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        [cookieArray addObject:cookie.name];
        NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
        cookieProperties[NSHTTPCookieName] = cookie.name;
        cookieProperties[NSHTTPCookieValue] = cookie.value;
        cookieProperties[NSHTTPCookieDomain] = cookie.domain;
        cookieProperties[NSHTTPCookiePath] = cookie.path;
        cookieProperties[NSHTTPCookieVersion] = @((int) cookie.version);
        cookieProperties[NSHTTPCookieExpires] = [[NSDate date] dateByAddingTimeInterval:2629743];
        
        [[NSUserDefaults standardUserDefaults] setValue:cookieProperties forKey:cookie.name];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:cookieArray forKey:@"CookieStorage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)load {
    NSMutableArray* cookieDictionary = [[NSUserDefaults standardUserDefaults] valueForKey:@"CookieStorage"];
    for (int i=0; i < cookieDictionary.count; i++) {
        NSMutableDictionary* cookieDictionary1 = [[NSUserDefaults standardUserDefaults] valueForKey:cookieDictionary[i]];
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieDictionary1];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
}

@end
