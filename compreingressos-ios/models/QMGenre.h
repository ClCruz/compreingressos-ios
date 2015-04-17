//
//  QMGenre.h
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 3/23/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMGenre : NSObject {
    
}

@property(nonatomic, strong) UIImage  *icon;
@property(nonatomic, strong) UIImage  *image;
@property(nonatomic, strong) NSString *iconUrl;
@property(nonatomic, strong) NSString *imageUrl;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *searchTerm;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
