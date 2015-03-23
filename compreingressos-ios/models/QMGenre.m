//
//  QMGenre.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 3/23/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMGenre.h"

@implementation QMGenre {
    @private
    UIImage  *_icon;
    UIImage  *_image;
    NSString *_iconUrl;
    NSString *_imageUrl;
    NSString *_title;
}

@synthesize icon = _icon;
@synthesize image = _image;
@synthesize iconUrl = _iconUrl;
@synthesize imageUrl = _imageUrl;
@synthesize title = _title;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _title = dictionary[@"title"];
        _iconUrl = dictionary[@"icon_url"];
        _imageUrl = dictionary[@"image_url"];
    }
    return self;
}

@end
