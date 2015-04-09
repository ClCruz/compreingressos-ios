//
//  QMEspetaculo.h
//  qprodelivery-ios
//
//  Created by Robinson Nakamura on 12/5/14.
//  Copyright (c) 2014 Qpro Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QMGenre;

@interface QMEspetaculo : NSObject

@property(nonatomic, strong) NSNumber *codigo;
@property(nonatomic, strong) NSString *titulo;
@property(nonatomic, strong) NSString *genero;
@property(nonatomic, strong) NSString *teatro;
@property(nonatomic, strong) NSString *cidade;
@property(nonatomic, strong) NSString *estado;
@property(nonatomic, strong) NSString *miniatura;
@property(nonatomic, strong) NSString *url;
@property(nonatomic, strong) NSString *data;
@property(nonatomic, strong) NSString *relevancia;
@property(nonatomic, weak)   QMGenre  *genre;

/* Dados do pedido */
@property(nonatomic, strong) NSString *horario;
@property(nonatomic, strong) NSString *endereco;


- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSString *)local;

@end
