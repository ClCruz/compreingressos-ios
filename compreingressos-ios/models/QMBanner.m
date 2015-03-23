//
// Created by Robinson Nakamura on 01/08/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "QMBanner.h"


@implementation QMBanner {

@private
    int _position;
    NSString *_description;
    NSString *_imageUrl;
    UIImage *_image;
    NSString *_updatedAt;
    int _bannerId;
    NSString *_linkUrl;
    BOOL _linkIsVideo;
}

@synthesize position = _position;
@synthesize description = _description;
@synthesize imageUrl = _imageUrl;
@synthesize image = _image;

@synthesize updatedAt = _updatedAt;

@synthesize bannerId = _bannerId;

@synthesize linkUrl = _linkUrl;

@synthesize linkIsVideo = _linkIsVideo;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _bannerId = [[dictionary valueForKeyPath:@"id"] intValue];
        _position = [[dictionary valueForKeyPath:@"position"] intValue];
        _linkIsVideo = [[dictionary valueForKeyPath:@"is_video"] boolValue];
        _description = [dictionary valueForKeyPath:@"description"];
        _description = self.description == (id) [NSNull null] ? nil : self.description;
        _imageUrl = [dictionary valueForKeyPath:@"mobile_image_url"];
        _imageUrl = self.imageUrl == (id) [NSNull null] ? nil : self.imageUrl;
        _linkUrl = [dictionary valueForKeyPath:@"link_url"];
        _linkUrl = self.linkUrl == (id) [NSNull null] ? nil : self.linkUrl;
        _updatedAt = [dictionary valueForKeyPath:@"updated_at"];
        _updatedAt = _updatedAt == (id) [NSNull null] ? nil : _updatedAt;
        [self addHttpToLinkIfNeeded];
    }
    return self;
}

- (void)addHttpToLinkIfNeeded {
    if (_linkUrl && _linkUrl.length > 0 && [_linkUrl rangeOfString:@"http"].location == NSNotFound) {
        _linkUrl = [NSString stringWithFormat:@"http://%@", _linkUrl];
    }
}

+ (NSArray *)sortBannersByPosition:(NSArray *)banners {
    NSArray *sortedBanners = [banners sortedArrayUsingComparator:^NSComparisonResult(QMBanner *banner1, QMBanner *banner2) {
        if (banner1.position <= banner2.position) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    return sortedBanners;
}

- (NSMutableDictionary *)toDictionary {
    return nil;
}

@end