//
//  QMRedPageControl.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 6/10/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMRedPageControl.h"

@implementation QMRedPageControl {
    UIImage *_activeImage;
    UIImage *_inactiveImage;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    _activeImage   = [UIImage imageNamed:@"page_control_empty.png"];
    _inactiveImage = [UIImage imageNamed:@"page_control_full.png"];
    return self;
}

-(void)updateDots {
    for (int i = 0; i < [self.subviews count]; i++) {
        UIImageView * dot = [self imageViewForSubview:self.subviews[(NSUInteger) i]];
        if (i == self.currentPage) {
            dot.image = _activeImage;
        } else {
            dot.image = _inactiveImage;
        }
    }
}

- (UIImageView *) imageViewForSubview: (UIView *) view {
    UIImageView * dot = nil;
    if ([view isKindOfClass: [UIView class]]) {
        for (UIView* subview in view.subviews) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                dot = (UIImageView *)subview;
                break;
            }
        }
        if (dot == nil) {
            dot = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, view.frame.size.width, view.frame.size.height)];
            [view addSubview:dot];
        }
    } else {
        dot = (UIImageView *) view;
    }
    return dot;
}

-(void)setCurrentPage:(NSInteger)page {
    [super setCurrentPage:page];
    [self updateDots];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateDots];
}


@end
