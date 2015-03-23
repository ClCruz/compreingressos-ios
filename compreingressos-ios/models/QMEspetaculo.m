//
//  QMEspetaculo.m
//  qprodelivery-ios
//
//  Created by Robinson Nakamura on 12/5/14.
//  Copyright (c) 2014 Qpro Mobile. All rights reserved.
//

#import "QMEspetaculo.h"

@implementation QMEspetaculo {
    @private
    NSNumber *_codigo;
    NSString *_titulo;
    NSString *_genero;
    NSString *_teatro;
    NSString *_cidade;
    NSString *_estado;
    NSString *_miniatura;
    NSString *_url;
    NSString *_data;
    NSString *_relevancia;
}

@synthesize codigo = _codigo;
@synthesize titulo = _titulo;
@synthesize genero = _genero;
@synthesize teatro = _teatro;
@synthesize cidade = _cidade;
@synthesize estado = _estado;
@synthesize miniatura = _miniatura;
@synthesize url = _url;
@synthesize data = _data;
@synthesize relevancia = _relevancia;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _titulo = dictionary[@"titulo"];
        _genero = dictionary[@"genero"];
        _teatro = dictionary[@"teatro"];
        _cidade = dictionary[@"cidade"];
        _estado = dictionary[@"estado"];
        _miniatura = dictionary[@"miniatura"];
        _url = dictionary[@"url"];
        _data = dictionary[@"data"];
        _relevancia = dictionary[@"relevancia"];
    }
    return self;
}

- (NSString *)local {
    return [NSString stringWithFormat:@"%@ - %@", _cidade, _estado];
}


@end
