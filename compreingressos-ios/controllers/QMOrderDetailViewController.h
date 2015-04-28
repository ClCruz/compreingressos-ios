//
//  QMOrderDetailViewController.h
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 4/13/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMOrder;

@interface QMOrderDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic)         BOOL     isModal;
@property (strong, nonatomic) QMOrder *order;

@end
