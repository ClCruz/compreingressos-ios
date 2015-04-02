//
//  QMEspetaculosGridHeaderView.m
//  qprodelivery-ios
//
//  Created by Robinson Nakamura on 12/8/14.
//  Copyright (c) 2014 Qpro Mobile. All rights reserved.
//

#import "QMEspetaculosGridHeaderView.h"
#import "QMCarouselView.h"
#import "QMVisor.h"
#import "QMBanner.h"
#import "QMConstants.h"

@implementation QMEspetaculosGridHeaderView {
    @private
    QMCarouselView *_carrossel;
    NSMutableArray *_banners;
    NSArray *_visores;
}

@synthesize visores = _visores;

- (void)awakeFromNib {
    _carrossel = [QMCarouselView allocFromNib];
    [self addSubview:_carrossel];
    _carrossel.frame = self.frame;
    [_carrossel prepareCarouselForRetina4:[QMConstants isRetina4]];
    [_carrossel setBackgroundColor:UIColorFromRGB(0xefeff4)];
    [_carrossel setShowBannerDescription:NO];
    [_carrossel setShowLinkButton:NO];
    [_carrossel setIsWebviewLink:YES];
    [_carrossel stopSpinner];
    CGFloat h1 = _carrossel.frame.size.height;
    CGFloat h2 = self.frame.size.height;
    self.frame = CGRectSetSize(self.frame, _carrossel.frame.size);
    NSLog(@"@@ (%f, %f)", self.frame.size.width, self.frame.size.height);
}

- (void)setVisores:(NSArray *)visores {
    _visores = visores;
    _banners = [[NSMutableArray alloc] init];
    for (QMVisor *visor in visores) {
        [_banners addObject:[visor toBanner]];
    }
    [_carrossel setBanners:_banners];
    NSLog(@"@@ (%f, %f)", self.frame.size.width, self.frame.size.height);
}

@end
