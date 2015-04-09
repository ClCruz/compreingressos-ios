//
//  QMEspetaculo.m
//  qprodelivery-ios
//
//  Created by Robinson Nakamura on 12/5/14.
//  Copyright (c) 2014 Qpro Mobile. All rights reserved.
//

#import "QMEspetaculo.h"
#import "QMRequester.h"
#import "QMGenre.h"

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
    NSString *_horario;
    NSString *_endereco;
    __weak QMGenre *_genre;
}

@synthesize codigo     = _codigo;
@synthesize titulo     = _titulo;
@synthesize genero     = _genero;
@synthesize teatro     = _teatro;
@synthesize cidade     = _cidade;
@synthesize estado     = _estado;
@synthesize miniatura  = _miniatura;
@synthesize url        = _url;
@synthesize data       = _data;
@synthesize relevancia = _relevancia;
@synthesize horario    = _horario;
@synthesize endereco   = _endereco;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _titulo     = dictionary[@"titulo"];
        _genero     = [QMRequester objectOrNilForKey:@"genero"     forDictionary:dictionary];
        _teatro     = [QMRequester objectOrNilForKey:@"teatro"     forDictionary:dictionary];
        _cidade     = [QMRequester objectOrNilForKey:@"cidade"     forDictionary:dictionary];
        _estado     = [QMRequester objectOrNilForKey:@"estado"     forDictionary:dictionary];
        _miniatura  = [QMRequester objectOrNilForKey:@"miniatura"  forDictionary:dictionary];
        _url        = [QMRequester objectOrNilForKey:@"url"        forDictionary:dictionary];
        _data       = [QMRequester objectOrNilForKey:@"data"       forDictionary:dictionary];
        _relevancia = [QMRequester objectOrNilForKey:@"relevancia" forDictionary:dictionary];
        if (!_teatro) _teatro = [QMRequester objectOrNilForKey:@"nome_teatro" forDictionary:dictionary];
        
        /* Dados que vem do pedido */
        _horario    = [QMRequester objectOrNilForKey:@"horario"    forDictionary:dictionary];
        _endereco   = [QMRequester objectOrNilForKey:@"endereco"   forDictionary:dictionary];
    }
    return self;
}

- (NSMutableDictionary *)toDictionary {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    dictionary[@"titulo"] = _titulo;
    dictionary[@"nome_teatro"] = _teatro;
    dictionary[@"horario"] = _horario;
    dictionary[@"endereco"] = _endereco;
    return dictionary;
}

- (NSString *)local {
    return [NSString stringWithFormat:@"%@ - %@", _cidade, _estado];
}

@end
