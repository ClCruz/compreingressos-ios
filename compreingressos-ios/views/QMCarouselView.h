//
//  QMCarouselView.h
//  qprodelivery-ios
//
//  Created by Robinson Nakamura on 18/04/13.
//  Copyright (c) 2013 Qpro Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "compreingressos-ios-Prefix.pch"

@class QMRedPageControl;

@interface QMCarouselView : UITableViewCell <UIScrollViewDelegate> {
    
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UIActivityIndicatorView *_spinner;
    __weak IBOutlet QMRedPageControl *_pageControlBg;
    CGFloat _pageWidth;
    NSTimer *caroselTimer;
    BOOL isRetina4; // fala se devemos renderizar para retina 3.5 ou retina 4 polegadas
    CGFloat _bannersHeight;
    NSMutableArray *_bannerViews;
}

@property (nonatomic, strong) NSArray *banners;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;

/* Se true, mostra o linkButton se houver um link associado ao banner.
 * Se false, não mostra o linkButton mas se houver um link associado ao
 * banner então segue o link caso o usuário toque o banner inteiro */
@property (nonatomic) BOOL showLinkButton;

/* Se true, abre o link em uma webview no próprio app.
 * Se false, abre o link no safari */
@property (nonatomic) BOOL isWebviewLink;

@property (nonatomic) BOOL showBannerDescription;

+ (QMCarouselView *)allocFromNib;
- (void)configure:(BOOL)retina4;
- (void)resetCaroselTimer;
- (void)stopCaroselTimer;
- (void)showNextBanner;
- (void)forceCurrentPage;

- (void)stopSpinner;

- (void)retryFailedBanners;

- (void)showError;

- (void)showLoading;
@end
