//
//  QMPaymentFinalizationViewController.h
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 4/23/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMPaymentFinalizationViewController : UIViewController

/* No caso de assinaturas, não mostraremos o botão "Ver Ingresso" */
@property (nonatomic) BOOL showTicketsButton;

- (IBAction)clickedOrderHistory:(id)sender;

@end
