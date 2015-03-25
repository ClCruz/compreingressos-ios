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
    QMGenre     *_genre;
    UIImageView *_imageView;
    UIImageView *_iconImageView;
    UILabel     *_titleLabel;
}

@synthesize genre = _genre;
@synthesize imageView = _imageView;
@synthesize iconImageView = _iconImageView;
@synthesize titleLabel = _titleLabel;

- (void)setGenre:(QMGenre *)genre {
    _genre = genre;
    [_titleLabel setText:_genre.title];
    [_iconImageView setImage:[UIImage imageNamed:_genre.iconUrl]];
}

@end
