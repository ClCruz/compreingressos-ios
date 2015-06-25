//
//  QMCarouselView.m
//  qprodelivery-ios
//
//  Created by Robinson Nakamura on 18/04/13.
//  Copyright (c) 2013 Qpro Mobile. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "QMCarouselView.h"
#import "QMBanner.h"
#import "QMBannerView.h"
#import "QMRedPageControl.h"
#import "QMLoadingView.h"

static const int kCarrosselPeriod = 5;
static const int kBannersHeightRetina4 = 156;
static const int kBannersHeightRetina3 = 156;

@implementation QMCarouselView {
@private
    NSArray *_banners;
    QMRedPageControl *_pageControl;
    BOOL _showLinkButton;
    BOOL _isWebviewLink;
    BOOL _showBannerDescription;
    UIImageView *_staticBackground;
    QMLoadingView *_loading;
    UIImageView *_logo;
    UIView *_background;
    BOOL _finishedInitialAnimation;
}

@synthesize banners = _banners;
@synthesize pageControl = _pageControl;
@synthesize showLinkButton = _showLinkButton;
@synthesize isWebviewLink = _isWebviewLink;
@synthesize showBannerDescription = _showBannerDescription;

+ (QMCarouselView *)allocFromNib {
    NSString *NibName = @"QMCarouselView";
    QMCarouselView *view = [[NSBundle mainBundle] loadNibNamed:NibName owner:nil options:nil][0];
    return view;
}

- (void)awakeFromNib {
    [self setClipsToBounds:YES];
    _bannerViews = [[NSMutableArray alloc] init];
    [_pageControlBg setBackgroundColor:[UIColor clearColor]];
    self.backgroundColor = [UIColor clearColor];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (CGFloat)carouselHeight {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat carouselHeight = screenWidth / 1.8f;
    return carouselHeight;
}

- (void)prepareCarouselForRetina4:(BOOL)retina4 {
    isRetina4 = retina4;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat carouselHeight = [self carouselHeight];
    _bannersHeight = carouselHeight;
    self.frame = CGRectSetWidth(self.frame, screenWidth);
    self.frame = CGRectSetHeight(self.frame, carouselHeight);
    scrollView.frame = CGRectSetSize(scrollView.frame, [QMBannerView sizeForBanner]);

    _staticBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"banner_placeholder.jpg"]];
    _staticBackground.frame = self.frame;
    [_staticBackground setContentMode:UIViewContentModeScaleAspectFill];
    [self addSubview:_staticBackground];
    _background = _staticBackground;

    _logo = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 81.0f, 59.0f)];
    [_logo setImage:[UIImage imageNamed:@"compreingressos_quebra.png"]];
    [_background addSubview:_logo];
    _logo.center = _background.center;

    _loading = [[QMLoadingView alloc] init];
    _loading.center = _background.center;
    _loading.frame = CGRectOffset(_loading.frame, 0.0, 40.0);
    [_background addSubview:_loading];
    _loading.alpha = 0.0f;
    [_loading start];
    [UIView animateWithDuration:0.6 delay:0.8 options:0 animations:^{
        _logo.frame = CGRectSetOriginY(_logo.frame, _logo.frame.origin.y - 40);
        _loading.alpha = 1.0f;
    } completion:^(BOOL finished) {
        _finishedInitialAnimation = YES;
        if([_banners count] > 0) {
            [self hideBackground];
        }
    }];

    [self sendSubviewToBack:_background];
}

- (void)hideBackground {
    [UIView animateWithDuration:0.3 animations:^{
        _logo.alpha = 0.0;
        _loading.alpha = 0.0;
//        [_background setAlpha:0.0];
    } completion:^(BOOL finished) {
        [_loading stop];
    }];
}

- (void)setBanners:(NSArray *)banners {
    _banners = banners;
    [_bannerViews enumerateObjectsUsingBlock:^(QMBannerView *view, NSUInteger idx, BOOL *stop) {
        [view removeFromSuperview];
    }];
    [_bannerViews removeAllObjects];
    [self configureScrollView];
    [self resetCaroselTimer];
    [UIView animateWithDuration:0.3 animations:^{
        [_pageControl setHidden:_pageControl.numberOfPages <= 1];
        if (_finishedInitialAnimation) {
            [_background setAlpha:0.0];
        }
    } completion:^(BOOL finished) {
    }];
    _pageControl.center = _pageControlBg.center;
}

- (void)resetCaroselTimer {
    if (caroselTimer) {
        [caroselTimer invalidate];
    }
    NSDate *initFireDate = [NSDate dateWithTimeIntervalSinceNow:kCarrosselPeriod];
    caroselTimer = [[NSTimer alloc] initWithFireDate:initFireDate
                                                        interval:kCarrosselPeriod
                                                          target:self
                                                        selector:@selector(showNextBanner)
                                                        userInfo:nil
                                                         repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:caroselTimer forMode:NSRunLoopCommonModes];
}

- (void)stopCaroselTimer {
    if (caroselTimer) {
        [caroselTimer invalidate];
    }
}

- (void)configureScrollView {
    [scrollView setDelegate:self];

    QMBannerView *bannerView = nil;
    for (NSUInteger i=0; i<[_banners count]; i++) {
        QMBanner *banner = _banners[i];
        bannerView = [QMBannerView allocFromNib];
        [bannerView setCarousel:self];
        [bannerView setBanner:banner];
        _pageWidth = CGRectGetWidth(bannerView.frame);
        [bannerView setFrame:CGRectSetOrigin(bannerView.frame, CGPointMake(_pageWidth * i, 0.0))];
        [bannerView setFrame:CGRectSetHeight(bannerView.frame, _bannersHeight)];
        [bannerView setBackgroundColor:self.backgroundColor]; // forward da backgroundcolor
        if (!_showBannerDescription) [bannerView hideDescription];
        [scrollView addSubview:bannerView];
        [bannerView setAlpha:0.0];
        [UIView animateWithDuration:0.2 animations:^{
            [bannerView setAlpha:1.0];
        }];
        [_bannerViews addObject:bannerView];
    }

    int pages = (int)[_banners count];
    CGFloat pageHeight = CGRectGetHeight(bannerView.frame);
    [scrollView setContentSize:CGSizeMake(_pageWidth * pages, pageHeight)];
    [_pageControl setNumberOfPages:pages];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView1 {
    int page = (int) (floor((scrollView.contentOffset.x - _pageWidth / 2) / _pageWidth) + 1);
    _pageControl.currentPage = page;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView1 willDecelerate:(BOOL)decelerate {
    [self resetCaroselTimer];
}

- (void)showNextBanner {
    int nextPageIndex = [self nextBannerIndex];
    CGPoint nextPageOffset = [self offsetForBannerAtIndex:nextPageIndex];
    [scrollView setContentOffset:nextPageOffset animated:YES];
}

- (void)forceCurrentPage {
    CGPoint nextPageOffset = [self offsetForBannerAtIndex:(int)_pageControl.currentPage];
    [scrollView setContentOffset:nextPageOffset animated:NO];
}

- (CGPoint)offsetForBannerAtIndex:(int)bannerIndex {
    CGFloat xPos = _pageWidth * bannerIndex;
    return CGPointMake(xPos, 0.0);
}

- (int)nextBannerIndex {
    int nextPage = (int)_pageControl.currentPage + 1;
    nextPage = nextPage == _pageControl.numberOfPages ? 0 : nextPage;
    return nextPage;
}

- (void)stopSpinner {

}

- (void)startSpinner {

}

- (void)retryFailedBanners {
    for (QMBannerView *banner in _bannerViews) {
        if ([banner isUsingPlaceholder]) {
            [banner downloadPhoto];
        }
    }
}

@end

