//
//  QMBannerView.h
//  qprodelivery-ios
//
//  Created by Robinson Nakamura on 01/08/13.
//  Copyright (c) 2013 Qpro Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMBanner;
@class QMCarouselView;

@interface QMBannerView : UIView {
    IBOutlet UIImageView *_bannerImage;
    IBOutlet UILabel *_description;
    IBOutlet UIActivityIndicatorView *_spinner;
}

@property (nonatomic, strong) QMBanner *banner;
@property (strong, nonatomic) IBOutlet UIView *descriptionCover;
@property (nonatomic, weak) QMCarouselView *carousel;

+ (QMBannerView *)allocFromNib;
- (void)hideDescription;

@end
