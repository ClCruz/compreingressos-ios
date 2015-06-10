//
//  QMHomeViewController.h
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 3/16/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface QMHomeViewController : UIViewController <UITableViewDataSource,
        UITableViewDelegate,
        CLLocationManagerDelegate,
        UICollectionViewDelegateFlowLayout,
        UIAlertViewDelegate>

@end
