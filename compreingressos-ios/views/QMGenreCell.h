//
//  QMGenreCell.h
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 3/23/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMGenre;

@interface QMGenreCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIImageView *iconImageView;
@property (strong, nonatomic) IBOutlet UILabel     *titleLabel;
@property(nonatomic, strong)           QMGenre     *genre;

@end
