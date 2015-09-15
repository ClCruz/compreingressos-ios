//
// Created by Robinson Nakamura on 9/15/15.
// Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMStatesChannelsHistory.h"

static QMStatesChannelsHistory *instance;

@implementation QMStatesChannelsHistory {
    /* Armazena o estado na chave e o timestamp que o estado foi adicionado no valor */
    NSMutableDictionary *_history;
}

+ (QMStatesChannelsHistory *)sharedInstance {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        if (!instance) {
            instance = [[QMStatesChannelsHistory alloc] init];
        }
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _history = [[NSUserDefaults standardUserDefaults] objectForKey:NSStringFromClass([QMStatesChannelsHistory class])];
        if (!_history) {
            _history = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (BOOL)contains:(NSString *)state {
    return [[_history allKeys] containsObject:state];
}

- (void)add:(NSString *)state {
    _history[state] = @((NSUInteger)[[[NSDate alloc] init] timeIntervalSince1970]);
    [self persist];
}

- (void)persist {
    [[NSUserDefaults standardUserDefaults] setObject:_history forKey:NSStringFromClass([QMStatesChannelsHistory class])];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end