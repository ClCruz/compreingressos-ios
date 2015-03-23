//
//  QMEventGridCell.h
//  qprodelivery-ios
//
//  Created by Robinson Nakamura on 12/4/14.
//  Copyright (c) 2014 Qpro Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMEspetaculo;

@interface QMEspetaculoCell : UICollectionViewCell

@property (strong, nonatomic) QMEspetaculo *espetaculo;
@property (strong, nonatomic) IBOutlet UILabel *titulo;
@property (strong, nonatomic) IBOutlet UILabel *teatro;
@property (strong, nonatomic) IBOutlet UILabel *local;
@property (strong, nonatomic) IBOutlet UILabel *genero;
@property (strong, nonatomic) IBOutlet UIImageView *image;

+ (CGSize)sizeForEspetaculo:(QMEspetaculo *)espetaculo;

@end
