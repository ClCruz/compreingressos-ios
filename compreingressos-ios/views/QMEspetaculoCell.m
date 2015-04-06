//
//  QMEventGridCell.m
//  qprodelivery-ios
//
//  Created by Robinson Nakamura on 12/4/14.
//  Copyright (c) 2014 Qpro Mobile. All rights reserved.
//

#import "QMEspetaculoCell.h"
#import "QMEspetaculo.h"
#import <SDWebImage/UIImageView+WebCache.h>


static UILabel *LabelForMetrics;
static CGRect originalTituloFrame;
static const CGFloat kImageBottomMargin = 8.0;

@implementation QMEspetaculoCell {
    @private
    QMEspetaculo *_espetaculo;
    UILabel *_titulo;
    UILabel *_genero;
    UILabel *_local;
    UILabel *_teatro;
    UIImageView *_image;
}

@synthesize espetaculo = _espetaculo;
@synthesize titulo = _titulo;
@synthesize genero = _genero;
@synthesize local = _local;
@synthesize teatro = _teatro;
@synthesize image = _image;

+ (CGSize)sizeForEspetaculo:(QMEspetaculo *)espetaculo {
    
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        LabelForMetrics = [[UILabel alloc] init];
        originalTituloFrame = CGRectMake(0.0, 0.0, 135.0, 25.0);
    });
    
//    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
//    CGFloat widthFactor = 1.0/320.0f;
//    CGFloat imageSide = 146.0f * widthFactor * screenWidth;
//    CGFloat cellWidth = imageSide + 8.0f;
    
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
    
    // NSLog(@"   altura %f", height);
    
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
    [_titulo setFrame:originalTituloFrame];
    [_titulo setText:espetaculo.titulo];
    [_genero setText:espetaculo.genero];
    [_teatro setText:espetaculo.teatro];
    [_local setText:[espetaculo local]];
    
    // _titulo.layer.borderColor = [[UIColor redColor] CGColor];
    // _titulo.layer.borderWidth = 1.0;
    
    [_titulo setNumberOfLines:0];
    [_titulo sizeToFit];
    _titulo.center = _genero.center;
    CGFloat tituloY = _image.frame.origin.y + _image.frame.size.height + kImageBottomMargin;
    _titulo.frame = CGRectSetOriginY(_titulo.frame, tituloY);
    CGFloat teatroY = _titulo.frame.origin.y + _titulo.frame.size.height + 5.0;
    _teatro.frame = CGRectSetOriginY(_teatro.frame, teatroY);
    CGFloat localY = _teatro.frame.origin.y + _teatro.frame.size.height + 3.0;
    _local.frame = CGRectSetOriginY(_local.frame, localY);
    CGFloat generoY = _local.frame.origin.y + _local.frame.size.height + 3.0;
    _genero.frame = CGRectSetOriginY(_genero.frame, generoY);
    
    [self configureImage];
}

- (void)configureImage {
    NSDictionary *viewsDictionary = @{@"imageView":_image};
    int imageSide = [QMEspetaculoCell imageSide];
    NSString *constraintHeightFormat = [NSString stringWithFormat:@"V:[imageView(%i)]", imageSide];
    NSString *constraintWidthFormat = [NSString stringWithFormat:@"H:[imageView(%i)]", imageSide];
    NSArray *constraintHeight = [NSLayoutConstraint constraintsWithVisualFormat:constraintHeightFormat options:0 metrics:nil views:viewsDictionary];
    NSArray *constraintWidth = [NSLayoutConstraint constraintsWithVisualFormat:constraintWidthFormat options:0 metrics:nil views:viewsDictionary];
    [_image addConstraints:constraintHeight];
    [_image addConstraints:constraintWidth];
    
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
