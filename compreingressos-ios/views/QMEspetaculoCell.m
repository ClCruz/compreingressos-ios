//
//  QMEventGridCell.m
//  qprodelivery-ios
//
//  Created by Robinson Nakamura on 12/4/14.
//  Copyright (c) 2014 Qpro Mobile. All rights reserved.
//

#import "QMEspetaculoCell.h"
#import "QMEspetaculo.h"
#import "QMConstants.h"
#import <SDWebImage/UIImageView+WebCache.h>

static UILabel *LabelForMetrics;
static CGRect originalTituloFrame;
static const CGFloat kImageBottomMargin = 8.0;

@implementation QMEspetaculoCell {
    @private
    QMEspetaculo *_espetaculo;
    UILabel      *_titulo;
    UILabel      *_genero;
    UILabel      *_local;
    UILabel      *_teatro;
    UIImageView  *_image;
}

@synthesize espetaculo = _espetaculo;
@synthesize titulo     = _titulo;
@synthesize genero     = _genero;
@synthesize local      = _local;
@synthesize teatro     = _teatro;
@synthesize image      = _image;

+ (CGSize)sizeForEspetaculo:(QMEspetaculo *)espetaculo {
    
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        LabelForMetrics = [[UILabel alloc] init];
        originalTituloFrame = CGRectMake(0.0, 0.0, 135.0, 25.0);
    });
    
    CGFloat cellWidth = [self cellWidth];
    CGFloat imageSide = [self imageSide];
    
    UILabel *tituloLabel = [[UILabel alloc] initWithFrame:originalTituloFrame];
    [tituloLabel setText:espetaculo.titulo];
    [tituloLabel setNumberOfLines:0];
    [tituloLabel sizeToFit];
    
    CGFloat height = imageSide + kImageBottomMargin;
    height += tituloLabel.frame.size.height + 3.0;
    height += 21.0 + 3.0;
    height += 21.0 + 3.0;
    height += 21.0 + 3.0;
    
    return CGSizeMake(cellWidth, height);
}

+ (CGFloat)cellWidth {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat cellWidth = (screenWidth - 12.0f) / 2.0f;
    return cellWidth;
}

+ (int)imageSide {
    return (int)(fabsf([self cellWidth]) - 8.0f);
}

- (void)setEspetaculo:(QMEspetaculo *)espetaculo {
    _espetaculo = espetaculo;
    [_titulo setText:espetaculo.titulo];
    [_genero setText:espetaculo.genero];
    [_teatro setText:espetaculo.teatro];
    [_local setText:[espetaculo local]];
    [_titulo setTextColor:UIColorFromRGB(kCompreIngressosDefaultRedColor)];
    
    [self configureImage];
}

- (void)configureImage {
    if (_espetaculo.miniatura) {
        @try {
//            __block UIActivityIndicatorView *imageActivityIndicator;
//            __weak UIImageView *weakImageView = _image;
            [_image sd_setImageWithURL:[NSURL URLWithString:_espetaculo.miniatura]
                               placeholderImage:nil
                                        options:0
                                       progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                                           if (!imageActivityIndicator) {
//                                               [weakImageView addSubview:imageActivityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
//                                               imageActivityIndicator.center = weakImageView.center;
//                                               [imageActivityIndicator startAnimating];
//                                           }
                                       }
                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                                          [imageActivityIndicator removeFromSuperview];
//                                          imageActivityIndicator = nil;
//                                          if (!image) {
//                                              [self dontHaveImage];
//                                          }
                                      }];
        }
        @catch (NSException *exception) {
            /* TODO: Usar handled exception do crittercism. Mas no pior caso não vai carregar a imagem */
        }
    } else {
//        [self dontHaveImage];
    }
}

@end
