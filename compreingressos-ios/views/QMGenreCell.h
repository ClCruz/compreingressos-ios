//
//  QMGenreCell.h
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 3/23/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMGenre;

@interface QMGenreCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView        *iconImageView;
@property (strong, nonatomic) IBOutlet UIImageView        *separator;
@property (strong, nonatomic) IBOutlet UILabel            *titleLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *leftMargin;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleLeftMargin;
@property (strong, nonatomic)          QMGenre            *genre;

@end
