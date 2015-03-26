//
//  QMCarouselView.m
//  qprodelivery-ios
//
//  Created by Robinson Nakamura on 18/04/13.
//  Copyright (c) 2013 Qpro Mobile. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "QMCarouselView.h"
#import "QMBanner.h"
#import "QMBannerView.h"

static const int kCarrosselPeriod = 5;
static const int kBannersHeightRetina4 = 156;
static const int kBannersHeightRetina3 = 156;

@implementation QMCarouselView {
@private
    NSArray *_banners;
    UIPageControl *_pageControl;
    BOOL _showLinkButton;
    BOOL _isWebviewLink;
    BOOL _showBannerDescription;
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
    [_spinner startAnimating];
    _bannerViews = [[NSMutableArray alloc] init];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [_spinner setCenter:self.center];
}

- (void)prepareCarouselForRetina4:(BOOL)retina4 {
    isRetina4 = retina4;
    _bannersHeight = isRetina4 ? kBannersHeightRetina4 : kBannersHeightRetina3;
//    self.frame = CGRectSetHeight(self.frame, _bannersHeight);
}

- (void)setBanners:(NSArray *)banners {
    _banners = banners;
    [_bannerViews enumerateObjectsUsingBlock:^(QMBannerView *view, NSUInteger idx, BOOL *stop) {
        [view removeFromSuperview];
    }];
    [_bannerViews removeAllObjects];
    [self configureScrollView];
    [self resetCaroselTimer];
    [UIView animateWithDuration:0.2 animations:^{
        [_spinner setAlpha:0.0];
        if (_pageControl.numberOfPages > 1) {
            [self generatePageControlBgView];
            [_pageControl setHidden:NO];
            [_pageControlBg setHidden:NO];
        } else {
            [_pageControl setHidden:YES];
            [_pageControlBg setHidden:YES];
        }
    } completion:^(BOOL finished) {
        [_spinner stopAnimating];
    }];
}

- (void)generatePageControlBgView {
    CGSize pageControlSize = [_pageControl sizeForNumberOfPages:_pageControl.numberOfPages];
    CGSize pageControlBgSize = _pageControlBg.frame.size;
    pageControlBgSize.width = pageControlSize.width + 20;
    _pageControlBg.frame = CGRectSetSize(_pageControlBg.frame, pageControlBgSize);
    [_pageControlBg setCenter:_pageControl.center];
    _pageControlBg.layer.cornerRadius = 5.0;
    [_pageControlBg.layer setRasterizationScale:[UIScreen mainScreen].scale];
    [_pageControlBg.layer shouldRasterize];
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
        QMBanner *banner = [_banners objectAtIndex:i];
        bannerView = [QMBannerView allocFromNib];
        [bannerView setCarousel:self];
        [bannerView setBanner:banner];
        _pageWidth = CGRectGetWidth(bannerView.frame);
        [bannerView setFrame:CGRectSetHeight(bannerView.frame, _bannersHeight)];
        [bannerView setFrame:CGRectSetOrigin(bannerView.frame, CGPointMake(_pageWidth * i, 0.0))];
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
    [_spinner stopAnimating];
}

- (void)startSpinner {
    [_spinner startAnimating];
}

@end
