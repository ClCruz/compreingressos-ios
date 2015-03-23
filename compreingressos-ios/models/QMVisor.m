//
//  QMVisor.m
//  qprodelivery-ios
//
//  Representa um Banner do compreingressos.com.br. Os atributos seguem a mesma nomenclatura
//  que o json retornado por eles.
//
//  Created by Robinson Nakamura on 12/8/14.
//  Copyright (c) 2014 Qpro Mobile. All rights reserved.
//

#import "QMVisor.h"
#import "QMBanner.h"

@implementation QMVisor {
    @private
    NSString *_imagem;
    NSString *_url;
}

@synthesize imagem = _imagem;
@synthesize url = _url;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _imagem = dictionary[@"imagem"];
        _url = dictionary[@"url"];
    }
    return self;
}

- (QMBanner *)toBanner {
    QMBanner *banner = [[QMBanner alloc] init];
    banner.description = @"teste";
    banner.imageUrl = _imagem;
    banner.linkUrl = _url;
    return banner;
}

@end
