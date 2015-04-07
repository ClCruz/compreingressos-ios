//
//  QMGenreView.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 4/6/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMGenreView.h"
#import "QMGenre.h"

@implementation QMGenreView {
    @private
    UIImageView *_imageView;
    UILabel *_title;
    QMGenre *_genre;
    __weak id<QMGenreViewDelegate> _delegate;
}

@synthesize imageView = _imageView;
@synthesize title = _title;
@synthesize genre = _genre;
@synthesize delegate = _delegate;

- (void)awakeFromNib {
    UITapGestureRecognizer *carouselTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMe)];
    [carouselTapGesture setNumberOfTapsRequired:1];
    [self addGestureRecognizer:carouselTapGesture];
}

- (void)setGenre:(QMGenre *)genre {
    _genre = genre;
    [_title setText:genre.title];
    [_imageView setImage:[UIImage imageNamed:_genre.imageUrl]];
}

- (void)didTapMe {
    [_delegate didSelectGenre:_genre];
}

@end
