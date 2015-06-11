//
//  QMHomeViewController.h
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 3/16/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "QMSuperViewController.h"

@interface QMHomeViewController : QMSuperViewController <UITableViewDataSource,
        UITableViewDelegate,
        CLLocationManagerDelegate,
        UICollectionViewDelegateFlowLayout>

@end
