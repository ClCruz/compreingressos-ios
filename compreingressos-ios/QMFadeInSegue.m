//
//  QMFadeInSegue.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 4/23/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMFadeInSegue.h"

@implementation QMFadeInSegue

- (void)perform {
    UIViewController *sourceViewController = self.sourceViewController;
    UIViewController *destinationViewController = self.destinationViewController;
    
    [sourceViewController.view addSubview:destinationViewController.view];
    
    destinationViewController.view.alpha = 0.0;
    [UIView animateWithDuration:0.4 animations:^{
        destinationViewController.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [destinationViewController.view removeFromSuperview];
        [sourceViewController.navigationController pushViewController:destinationViewController animated:NO];
    }];
}

@end
