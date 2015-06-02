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
#import <Google/Analytics.h>

@interface QMPaymentFinalizationViewController ()

@end

@implementation QMPaymentFinalizationViewController {

@private
    IBOutlet UIScrollView       *_scrollView;
    IBOutlet UILabel            *_lastLabel;
    IBOutlet UIButton           *_seeTicketsButton;
    IBOutlet NSLayoutConstraint *_verticalSpace1; /* entre bt 'Ver Ingressos' e a label 'Seus ingressos...' */
    BOOL                        _showTicketsButton;

}

@synthesize showTicketsButton = _showTicketsButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat height = _lastLabel.frame.origin.y + _lastLabel.frame.size.height + 30.0f;
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, height)];
    
    UIBarButtonItem *buttonForLogo = [[UIBarButtonItem alloc] initWithTitle:@"Logo" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.leftBarButtonItem = buttonForLogo;
    UIImageView *compreIngressos = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ingressos.png"]];
    compreIngressos.alpha = 0.0;
    [buttonForLogo setCustomView:compreIngressos];

    if (!_showTicketsButton) {
        [_seeTicketsButton setHidden:YES];
        [_verticalSpace1 setConstant:-40.0f];
    }
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
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Finalização Pagamento"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
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
