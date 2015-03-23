//
//  QMConstants.h
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 3/23/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *const kCompreIngressosURL = @"http://www.compreingressos.com/espetaculos";

static NSString *const kOpenEspetaculoWebviewNotificationTag = @"kOpenEspetaculoWebviewNotificationTag";

static const float kRetina3Height = 480.0;

@interface QMConstants : NSObject

+ (BOOL)isRetina4;
//+ (UIImage *)placeHolderImage;

@end
