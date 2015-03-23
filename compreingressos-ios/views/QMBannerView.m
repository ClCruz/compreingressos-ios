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
#import <SDWebImage/UIImageView+WebCache.h>

@implementation QMBannerView {
@private
    QMBanner *_banner;
    UIView *_descriptionCover;
    __weak QMCarouselView *_carousel;
}

@synthesize banner = _banner;
@synthesize descriptionCover = _descriptionCover;
@synthesize carousel = _carousel;

- (void)awakeFromNib {
    [_spinner removeFromSuperview];
}

- (void)setBanner:(QMBanner *)banner {
    _banner = banner;
    [self configurePhoto];
    [_description setFont:[UIFont boldSystemFontOfSize:16]];
    [_description setText:_banner.description];
    [self configureLink];
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

- (void)configurePhoto {
    [_bannerImage setImage:nil];
    if (_banner.imageUrl) {
        @try {
            __block UIActivityIndicatorView *imageActivityIndicator;
            __weak UIImageView *weakImageView = _bannerImage;
            [_bannerImage sd_setImageWithURL:[NSURL URLWithString:_banner.imageUrl]
                            placeholderImage:nil
                                     options:0
                                    progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                if (!imageActivityIndicator) {
                    [weakImageView addSubview:imageActivityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
                    imageActivityIndicator.center = weakImageView.center;
                    [imageActivityIndicator startAnimating];
                }
            }
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [imageActivityIndicator removeFromSuperview];
                imageActivityIndicator = nil;
                if (!image) {
//                    [_bannerImage setImage:[QMConstants placeHolderImage]];
                }
            }];
        }
        @catch (NSException *exception) {
            /* TODO: Usar handled exception do crittercism. Mas no pior caso não vai carregar a imagem */
        }
    }
}

- (void)showImage:(UIImage *)image {
    [_bannerImage setImage:image];
    _bannerImage.alpha = 0.0;
    _description.alpha = 0.0;
    [UIView animateWithDuration:0.2 animations:^{
        _bannerImage.alpha = 1.0;
        _description.alpha = 1.0;
        _spinner.alpha = 0.0;
    } completion:^(BOOL finished) {
        [_spinner stopAnimating];
    }];
}

- (BOOL)hasLink {
    return (_banner.linkUrl && _banner.linkUrl.length > 0);
}

- (void)configureLink {
    if ([self hasLink]) {
        if ([_carousel showLinkButton]) {
            if (_banner.linkIsVideo) {
                UIButton *play = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 80.0, 80.0)];
                [play addTarget:self action:@selector(clickedOnVideoButton) forControlEvents:UIControlEventTouchUpInside];
                [play setImage:[UIImage imageNamed:@"ic_play_n.png"] forState:UIControlStateNormal];
                [self addSubview:play];
                play.center = self.center;
                CGFloat deltaY = 10.0;
                if (![QMConstants isRetina4]) {
                    deltaY = 54.0;
                }
                CGPoint origin = CGPointMake(play.frame.origin.x, play.frame.origin.y - deltaY);
                play.frame = CGRectSetOrigin(play.frame, origin);
            } else {
                UIButton *link = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 40.0, 40.0)];
                [link addTarget:self action:@selector(clickedOnLinkButton) forControlEvents:UIControlEventTouchUpInside];
                [link setImage:[UIImage imageNamed:@"ic_link_n.png"] forState:UIControlStateNormal];
                [self addSubview:link];
                link.frame = CGRectSetOrigin(link.frame, CGPointMake(25.0f, -5.0f));
            }
        } else {
            UIButton *link = [[UIButton alloc] initWithFrame:self.frame];
            [link addTarget:self action:@selector(clickedOnLinkButton) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:link];
        }
    }
}

- (void)clickedOnLinkButton {
    [self openUrl];
}

- (void)clickedOnVideoButton {
    [self openUrl];
}

- (void)openUrl {
    if ([_carousel isWebviewLink]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kOpenEspetaculoWebviewNotificationTag
                                                            object:self
                                                          userInfo:@{@"url":_banner.linkUrl}];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_banner.linkUrl]];
    }
}

@end
