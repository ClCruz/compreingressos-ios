//
//  QMBannerView.m
//  qprodelivery-ios
//
//  Created by Robinson Nakamura on 01/08/13.
//  Copyright (c) 2013 Qpro Mobile. All rights reserved.
//

#import "QMBannerView.h"
#import "QMBanner.h"
#import "QMCarouselView.h"
#import "QMConstants.h"
#import "QMException.h"
#import "QMLoadingView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation QMBannerView {
@private
    QMBanner *_banner;
    UIView *_descriptionCover;
    __weak QMCarouselView *_carousel;
    BOOL _isUsingPlaceholder;
    __block QMLoadingView *_loadingView;
}

@synthesize banner = _banner;
@synthesize descriptionCover = _descriptionCover;
@synthesize carousel = _carousel;

@synthesize isUsingPlaceholder = _isUsingPlaceholder;

+ (CGSize)sizeForBanner {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat bannerWidth = screenWidth / 0.865f;
    CGFloat bannerHeight = screenWidth / 1.8f;
    return CGSizeMake(bannerWidth, bannerHeight);
}

- (void)awakeFromNib {
    [_spinner removeFromSuperview];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(clickedOnLinkButton)];
    singleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTap];
    self.frame = CGRectSetSize(self.frame, [QMBannerView sizeForBanner]);
    [self setBackgroundColor:[UIColor clearColor]];
    [_bannerImage setBackgroundColor:[UIColor clearColor]];
}

- (void)setBanner:(QMBanner *)banner {
    _banner = banner;
    [self downloadPhoto];
    [_description setFont:[UIFont boldSystemFontOfSize:16]];
    [_titleLabel setText:_banner.description];
    if (!_banner.description) {
        [_titleContainer removeFromSuperview];
        _titleContainer = nil;
    }
}

- (void)hideDescription {
    [_descriptionCover setHidden:YES];
    [_description setHidden:YES];
}

+ (QMBannerView *)allocFromNib {
    NSString *NibName = @"QMBannerView";
    QMBannerView *view = [[NSBundle mainBundle] loadNibNamed:NibName owner:nil options:nil][0];
    return view;
}

- (void)downloadPhoto {
    [_bannerImage setImage:nil];
    if (_banner.imageUrl) {
        @try {
            __weak UIImageView *weakImageView = _bannerImage;
            _bannerImage.alpha = 0.0f;
            [_bannerImage sd_setImageWithURL:[NSURL URLWithString:_banner.imageUrl]
                            placeholderImage:[UIImage imageNamed:@"banner_placeholder.jpg"]
                                     options:0
                                    progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                        if (!_loadingView) {
                                            _loadingView = [[QMLoadingView alloc] init];
                                            [self addSubview:_loadingView];
                                            _loadingView.center = weakImageView.center;
                                            if (_titleContainer) {
                                                _loadingView.frame = CGRectOffset(_loadingView.frame, 0.0, 40.0);
                                            }
                                            [_loadingView start];
                                        }
            }
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
                                           fadeIn.fromValue = @0.0F;
                                           fadeIn.toValue = @1.0F;
                                           fadeIn.duration = 0.3;

                                           CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
                                           fadeOut.fromValue = @1.0F;
                                           fadeOut.toValue = @0.0F;
                                           fadeOut.duration = 0.3;
                                           fadeOut.delegate = self;

                                           [weakImageView.layer addAnimation:fadeIn forKey:@"opacity"];
                                           weakImageView.layer.opacity = 1.0;

                                           [_loadingView.layer addAnimation:fadeOut forKey:@"opacity"];
                                           _loadingView.layer.opacity = 0.0;

                                           if (_titleContainer) {
                                               [_titleContainer.layer addAnimation:fadeOut forKey:@"opacity"];
                                               _titleContainer.layer.opacity = 0.0;
                                           }
                                       });
                                       if (image) {
                                           _isUsingPlaceholder = NO;
                                       } else {
                                           _isUsingPlaceholder = YES;
                                       }
            }];
        }
        @catch (NSException *exception) {
            /* TODO: Usar handled exception do crittercism. Mas no pior caso não vai carregar a imagem */
            QMException *handled = [[QMException alloc] initWithNSException:exception];
            [handled addPrefixToTitle:@"[Não carregou banner]"];
            handled.moreInfo = _banner.imageUrl;
            [handled post];
            _isUsingPlaceholder = YES;
        }
    }
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    if (_loadingView) {
        [_loadingView stop];
        [_loadingView removeFromSuperview];
        _loadingView = nil;
    }
}

- (BOOL)hasLink {
    return (_banner.linkUrl && _banner.linkUrl.length > 0);
}

- (void)clickedOnLinkButton {
    [self openUrl];
}

- (void)clickedOnVideoButton {
    [self openUrl];
}

- (void)openUrl {
        [[NSNotificationCenter defaultCenter] postNotificationName:kOpenEspetaculoWebviewNotificationTag
                                                            object:self
                                                          userInfo:@{@"url":_banner.linkUrl}];
}

@end
