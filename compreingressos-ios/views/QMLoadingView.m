//
// Created by Robinson Nakamura on 7/13/15.
// Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMLoadingView.h"

static UIImage *loadingImage;

@implementation QMLoadingView {
    UIImageView *_imageView;
}

- (id)init {
    self = [super init];
    if (self) {
        static dispatch_once_t token;
        dispatch_once(&token, ^{
            loadingImage = [UIImage imageNamed:@"custom_loading.png"];
        });
        CGRect frame = CGRectMake(0.0, 0.0, 39.0, 39.0);
        self.frame = frame;
        _imageView = [[UIImageView alloc] initWithFrame:frame];
        [_imageView setImage:loadingImage];
        [self addSubview:_imageView];
    }

    return self;
}


- (void)start {
    [self rotateLayerInfinite:_imageView.layer];
}

- (void)stop {
    [_imageView.layer removeAllAnimations];
}

- (void)rotateLayerInfinite:(CALayer *)layer {
    CABasicAnimation *rotation;
    rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.fromValue = @0.0F;
    rotation.toValue = @((float)(2 * M_PI));
    rotation.duration = 1.2f; // Speed
    rotation.repeatCount = HUGE_VALF; // Repeat forever. Can be a finite number.
    [layer removeAllAnimations];
    [layer addAnimation:rotation forKey:@"Spin"];
}

@end