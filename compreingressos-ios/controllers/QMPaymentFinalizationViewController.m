//
//  QMPaymentFinalizationViewController.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 4/23/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMPaymentFinalizationViewController.h"
#import "QMOrderDetailViewController.h"
#import "QMConstants.h"
#import "QMOrder.h"

@interface QMPaymentFinalizationViewController ()

@end

@implementation QMPaymentFinalizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Fechar" style:UIBarButtonItemStyleDone target:self action:@selector(clickedOnCloseButton:)];
    [closeButton setTintColor:UIColorFromRGB(kCompreIngressosDefaultRedColor)];
    self.navigationItem.rightBarButtonItem = closeButton;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"orderDetailSegue"]) {
        QMOrderDetailViewController *controller = segue.destinationViewController;
        [controller setIsModal:YES];
        [controller setOrder:[QMOrder orderHistory][0]];
    }
    [self configureNextViewBackButtonWithTitle:@"Voltar"];
    [super prepareForSegue:segue sender:sender];
}

- (void)configureNextViewBackButtonWithTitle:(NSString *)title {
    UIBarButtonItem *nextViewBackButton = [[UIBarButtonItem alloc] initWithTitle:title
                                                                           style:UIBarButtonItemStyleDone
                                                                          target:nil
                                                                          action:nil];
    [self.navigationItem setBackBarButtonItem:nextViewBackButton];
}


- (IBAction)clickedOnCloseButton:(id)sender {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    CATransition *transition = [CATransition animation];
    [transition setType:kCATransitionFade];
    [self.navigationController.view.layer addAnimation:transition forKey:@"someAnimation"];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    [CATransaction commit];

}

- (IBAction)clickedOrderHistory:(id)sender {
    [self performSegueWithIdentifier:@"orderDetailSegue" sender:nil];
}

@end
