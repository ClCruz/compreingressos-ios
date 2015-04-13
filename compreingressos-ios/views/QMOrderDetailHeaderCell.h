//
//  QMOrderDetailHeaderCell.h
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 4/14/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMOrder;

@interface QMOrderDetailHeaderCell : UITableViewCell

@property(strong, nonatomic) QMOrder *order;

@end
