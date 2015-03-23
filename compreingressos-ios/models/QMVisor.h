//
//  QMVisor.h
//  qprodelivery-ios
//
//  Created by Robinson Nakamura on 12/8/14.
//  Copyright (c) 2014 Qpro Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QMBanner;

@interface QMVisor : NSObject

@property(nonatomic, strong) NSString *imagem;
@property(nonatomic, strong) NSString *url;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (QMBanner *)toBanner;

@end
