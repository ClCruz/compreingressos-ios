//
//  QMGenreCell.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 3/23/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMGenreCell.h"
#import "QMGenre.h"

@implementation QMGenreCell {
    @private
    QMGenre            *_genre;
    UIImageView        *_iconImageView;
    UILabel            *_titleLabel;
    UIImageView        *_separator;
    NSLayoutConstraint *_leftMargin;
    NSLayoutConstraint *_titleLeftMargin;
}

@synthesize genre           = _genre;
@synthesize iconImageView   = _iconImageView;
@synthesize titleLabel      = _titleLabel;
@synthesize separator       = _separator;
@synthesize leftMargin      = _leftMargin;
@synthesize titleLeftMargin = _titleLeftMargin;

- (void)awakeFromNib {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    [_leftMargin setConstant:90.0f/320.0f * screenWidth];
    [_titleLeftMargin setConstant:15.0f/320.0f * screenWidth];

}

- (void)setGenre:(QMGenre *)genre {
    _genre = genre;
    [_titleLabel setText:genre.title];
    [_titleLabel setFont:[UIFont systemFontOfSize:17.0f/320.0f * [UIScreen mainScreen].bounds.size.width]];
    [_iconImageView setImage:[UIImage imageNamed:genre.iconUrl]];
}

@end
