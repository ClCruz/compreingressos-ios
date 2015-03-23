//
// Created by Robinson Nakamura on 01/08/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface QMBanner : NSObject

@property (nonatomic) int bannerId;
@property (nonatomic) int position;
@property (nonatomic) BOOL linkIsVideo;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *linkUrl;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *updatedAt;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSMutableDictionary *)toDictionary;

+ (NSArray *)sortBannersByPosition:(NSArray *)banners;

@end