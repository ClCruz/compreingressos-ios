//
// Created by Robinson Nakamura on 6/17/15.
// Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMException.h"
#import "QMExceptionsRequester.h"


@implementation QMException {

@private
    NSString *_title;
    NSString *_desc;
    NSString *_stacktrace;
    NSString *_moreInfo;
}

@synthesize title      = _title;
@synthesize desc       = _desc;
@synthesize stacktrace = _stacktrace;
@synthesize moreInfo   = _moreInfo;

- (id)initWithNSException:(NSException *)exception {
    self = [super init];
    if (self) {
        _title = exception.name;
        _desc = exception.reason;
        _stacktrace = [NSString stringWithFormat:@"%@", [exception callStackSymbols]];
    }
    return self;
}

- (id)initWithNSError:(NSError *)error {
    self = [super init];
    if (self) {
        NSString *code = error.code ? [NSString stringWithFormat:@"%i", error.code] : @"code";
        NSString *domain = error.domain ? error.domain : @"domain";
        _title = [NSString stringWithFormat:@"[%@] - %@", code, domain];
        _desc = error.localizedDescription;
        _stacktrace = error.localizedFailureReason;
    }
    return self;
}

- (void)addPrefixToTitle:(NSString *)prefix {
    _title = [NSString stringWithFormat:@"%@: %@", prefix, _title];
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (_title)      dict[@"title"]       = _title;
    if (_desc)       dict[@"description"] = _desc;
    if (_stacktrace) dict[@"stacktrace"]  = _stacktrace;
    if (_moreInfo)   dict[@"more_info"]   = _moreInfo;
    return dict;
}


- (void)post {
    [QMExceptionsRequester postExceptionWith:self onCompleteBlock:nil onFailBlock:nil];
}
@end