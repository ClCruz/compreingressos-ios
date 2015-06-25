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
    [_bannerImage setOpaque:NO];
    self.frame = CGRectSetSize(self.frame, [QMBannerView sizeForBanner]);
}

- (void)setBanner:(QMBanner *)banner {
    _banner = banner;
    [self downloadPhoto];
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

- (void)downloadPhoto {
    [_bannerImage setImage:nil];
    if (_banner.imageUrl) {
        @try {
            __block QMLoadingView *imageActivityIndicator;
            __weak UIImageView *weakImageView = _bannerImage;
            [_bannerImage sd_setImageWithURL:[NSURL URLWithString:_banner.imageUrl]
                            placeholderImage:[UIImage imageNamed:@"banner_placeholder.jpg"]
                                     options:0
                                    progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                        if (!imageActivityIndicator) {
                                            imageActivityIndicator = [[QMLoadingView alloc] init];
                                            imageActivityIndicator.frame = CGRectOffset(imageActivityIndicator.frame, 0.0, 40.0);
                                            [weakImageView addSubview:imageActivityIndicator];
                                            imageActivityIndicator.center = weakImageView.center;
                                            CGFloat x = [UIScreen mainScreen].bounds.size.width - imageActivityIndicator.frame.size.width;
                                            imageActivityIndicator.frame = CGRectSetOriginX(imageActivityIndicator.frame, x/2.0f);
                                            [imageActivityIndicator start];
                                        }
            }
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                                       [weakImageView layoutIfNeeded];
                                       weakImageView.alpha = 0.0;
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [UIView animateWithDuration:0.3 animations:^{
                                               weakImageView.alpha = 1.0;
                                               imageActivityIndicator.alpha = 0.0;
                                           } completion:^(BOOL finished) {
                                               [imageActivityIndicator stop];
                                               [imageActivityIndicator removeFromSuperview];
                                               imageActivityIndicator = nil;
                                           }];
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

- (BOOL)hasLink {
    return (_banner.linkUrl && _banner.linkUrl.length > 0);
}

- (void)configureLink {
    if ([self hasLink]) {
        if ([_carousel showLinkButton]) {
            if (_banner.linkIsVideo) {
                UIButton *play = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 80.0, 80.0)];
                [play addTarget:self action:@selector(clickedOnVideoButton) forControlEvents:UIControlEventTouchUpInside];
                //[play setImage:[UIImage imageNamed:@"ic_play_n.png"] forState:UIControlStateNormal];
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
                //[link setImage:[UIImage imageNamed:@"ic_link_n.png"] forState:UIControlStateNormal];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:kOpenEspetaculoWebviewNotificationTag
                                                            object:self
                                                          userInfo:@{@"url":_banner.linkUrl}];
}

@end
