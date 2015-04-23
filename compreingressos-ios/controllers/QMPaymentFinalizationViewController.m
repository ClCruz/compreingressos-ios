//
//  QMPaymentFinalizationViewController.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 4/23/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMPaymentFinalizationViewController.h"
#import "QMConstants.h"

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)clickedOnCloseButton:(id)sender {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    CATransition *transition = [CATransition animation];
    [transition setType:kCATransitionFade];
    [self.navigationController.view.layer addAnimation:transition forKey:@"someAnimation"];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    [CATransaction commit];

}

@end
