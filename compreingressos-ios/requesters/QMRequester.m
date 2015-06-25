//
// Created by Robinson Nakamura on 12/03/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "QMRequester.h"
#import "QMReachability.h"

NSString *appVersionParameter;
CGFloat requestTimeoutSeconds = 15.0;

@implementation QMRequester {

}

+ (BOOL)offlineMode {
    return kOfflineMode;
}

+ (NSURLRequestCachePolicy)cachePolicy {
    return (kOfflineMode ? kOfflineCachePolicy : kDefaultCachePolicy);
}

+ (NSString *)getHost {
    NSString *host;

    #ifdef SERVER_PROD
        host = kProdHost;
    #endif

    #ifdef SERVER_HOMOL
        host = kHomolHost;
    #endif

    #ifdef SERVER_TEST
        host = kTestHost;
    #endif

    #ifdef SERVER_LOCAL
        host = kLocalHost;
    #endif

    return host;
}

+ (NSString *)getUrlForPath:(NSString *)path {
    NSString *host = [self getHost];
    NSString *url = [NSString stringWithFormat:@"%@/%@", host, path];
    return [self addVersionToUrl:url];
}

+ (dispatch_queue_t)getDispatchQueue {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

+ (CGFloat)requestTimeout {
    return requestTimeoutSeconds;
}

+ (void)setRequestTimeout:(CGFloat)timeout {
    requestTimeoutSeconds = timeout;
}

+ (BOOL)isTimeoutError:(NSError *)error {
    return error && error.domain && [error.domain isEqualToString:@"NSURLErrorDomain"] && error.code == 1001;
}

+ (NSError *)errorFromException:(NSException *)exception {
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setValue:exception.name forKey:@"MONExceptionName"];
    [info setValue:exception.reason forKey:@"MONExceptionReason"];
    [info setValue:exception.callStackReturnAddresses forKey:@"MONExceptionCallStackReturnAddresses"];
    [info setValue:exception.callStackSymbols forKey:@"MONExceptionCallStackSymbols"];
    [info setValue:exception.userInfo forKey:@"MONExceptionUserInfo"];

    return [[NSError alloc] initWithDomain:@"NSException" code:999 userInfo:info];
}

+ (NSError *)errorFromWsMessage:(NSString *)message {
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"NSLocalizedDescription"] = message;
    return [[NSError alloc] initWithDomain:@"WS Error" code:100 userInfo:info];
}

+ (NSError *)errorFromWsMessage:(NSString *)message forField:(NSString *)field {
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    if (!message) message = @"";
    info[@"NSLocalizedDescription"] = message;
    if (field) info[@"field"] = field;
    return [[NSError alloc] initWithDomain:@"WS Error" code:100 userInfo:info];
}

+ (void)printDebugMessageWithError:(NSError *)error withTag:(NSString *)tag {
    if (kDebug) {
        if (error && error.localizedDescription) {
            [self printDebugMessage:error.localizedDescription withTag:tag];
        }
    }
}

+ (void)printDebugMessage:(NSString *)message withTag:(NSString *)tag {
    if (kDebug) {
        NSLog(@"[%@] %@", tag, message);
    }
}

+ (NSString *)urlEncodeString:(NSString *)string {
    NSString *encoded = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
            NULL,
            (__bridge CFStringRef) string,
            NULL,
            CFSTR("!*'();:@&=+$,/?%#[]"),
            kCFStringEncodingUTF8));
    return encoded;
}

+ (NSString *)addVersionToUrl:(NSString *)url {
    static NSString *kQuestionMark = @"?";
    static NSString *kAndMark = @"&";
    NSMutableString *newUrl = [NSMutableString stringWithString:url];
    /* Se a url não possuir uma query string, vamos adicionar a interrogação */
    if ([url rangeOfString:kQuestionMark].length == 0) {
        [newUrl appendString:kQuestionMark];
    } else {
        [newUrl appendString:kAndMark];
    }
    [newUrl appendString:[self appVersion]];
    return [NSString stringWithString:newUrl];
}

+ (NSMutableString *)addQueryStringParamenter:(NSString *)parameter withValue:(NSString *)value toUrl:(NSString *)url {
    static NSString *kQuestionMark = @"?";
    static NSString *kAndMark = @"&";
    NSMutableString *newUrl = [NSMutableString stringWithString:url];
    /* Se a url não possuir uma query string, vamos adicionar a interrogação */
    if ([url rangeOfString:kQuestionMark].length == 0) {
        [newUrl appendString:kQuestionMark];
    } else {
        [newUrl appendString:kAndMark];
    }

    [newUrl appendString:parameter];
    [newUrl appendString:kEqualMark];
    [newUrl appendString:value];

    return newUrl;
}

+ (NSString *)appVersion {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        NSString *appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
        appVersionParameter = [NSString stringWithFormat:@"v=%@&os=ios", appVersion];
    });
    return appVersionParameter;
}

+ (id)objectOrNilForKey:(NSString *)key forDictionary:(NSDictionary *)dictionary {
    id object = dictionary[key];
    if (object == [NSNull null]) {
        return nil;
    }
    return object;
}

+ (BOOL)booleanForKey:(NSString *)key forDictionary:(NSDictionary *)dictionary {
    NSNumber *boolean = [QMRequester objectOrNilForKey:key forDictionary:dictionary];
    if (boolean) {
        return [boolean boolValue];
    } else {
        return false;
    }
}

+ (NSString *)connectionType {
    QMReachability *networkReachability = [QMReachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == ReachableViaWiFi) {
        return kWifiCon;
    } else {
        return kWwanCon;
    }
}

+ (BOOL)isWifi {
    return [[self connectionType] isEqualToString:kWifiCon];
}


@end