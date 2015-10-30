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
    __weak IBOutlet UIImageView *_bannerImage;
    __weak IBOutlet UILabel *_description;
    __weak IBOutlet UIActivityIndicatorView *_spinner;
    __weak IBOutlet UIView *_titleContainer;
    __weak IBOutlet UILabel *_titleLabel;
}

@property (nonatomic, strong) QMBanner *banner;
@property (strong, nonatomic) IBOutlet UIView *descriptionCover;
@property (nonatomic, weak) QMCarouselView *carousel;
@property (nonatomic) BOOL isUsingPlaceholder;

+ (QMBannerView *)allocFromNib;
+ (CGSize)sizeForBanner;
- (void)hideDescription;
- (void)downloadPhoto;

@end
