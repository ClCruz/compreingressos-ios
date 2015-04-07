//
//  QMGenreView.h
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 4/6/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMGenre;

@protocol QMGenreViewDelegate <NSObject>
- (void)didSelectGenre:(QMGenre *)genre;
@end

@interface QMGenreView : UIView

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) QMGenre *genre;
@property (weak, nonatomic) id<QMGenreViewDelegate> delegate;


@end
