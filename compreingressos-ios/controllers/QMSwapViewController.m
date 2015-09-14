//
//  QMSwapViewController.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 9/10/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMSwapViewController.h"
#import "QMOrderHistoryViewController.h"
#import "QMUser.h"
#import "QMConstants.h"

@interface QMSwapViewController ()

@end

@implementation QMSwapViewController {
@private
    UIViewController *_currentDetailViewController;
    __weak UIView *_detailView;
    BOOL _firstViewDidAppear;
}

@synthesize detailView = _detailView;

- (void)viewDidLoad {
    [super viewDidLoad];

    _firstViewDidAppear = YES;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    QMOrderHistoryViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"QMOrderHistoryViewController"];
    [self presentDetailViewController:controller];

    [self addLogoutButtonIfNeeded];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidLogin)
                                                 name:kUserLoginTag
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidLogout)
                                                 name:kUserLogoutTag
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_firstViewDidAppear) {
        _firstViewDidAppear = NO;
        if ([_currentDetailViewController isKindOfClass:[QMSuperViewController class]]) {
            [(QMSuperViewController *) _currentDetailViewController requestData];
        }
    }

    if (![[QMUser sharedInstance] hasHash]) {
        NSTimer *timer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:0.8]
                                                  interval:0.0
                                                    target:self
                                                  selector:@selector(showLogin)
                                                  userInfo:nil
                                                   repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
}

- (void)addLogoutButtonIfNeeded {
    if ([[QMUser sharedInstance] hasHash]) {
        UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(clickedOnLogoutButton)];
        [self.navigationItem setRightBarButtonItem:logoutButton];
    }
}

- (void)clickedOnLogoutButton {
    [[QMUser sharedInstance] logoutOnComplete:^{
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    } onFail:^(NSError *error) {

    }];
}

- (void)userDidLogin {
    [self addLogoutButtonIfNeeded];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    QMOrderHistoryViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"QMOrderHistoryViewController"];
    [self swapCurrentControllerWith:controller];
    [controller requestData];
}

- (void)userDidLogout {
    [self showLogin];
}

- (void)showLogin {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    QMOrderHistoryViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"QMLoginViewController"];
    [self swapCurrentControllerWith:controller];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentDetailViewController:(QMOrderHistoryViewController *)controller {
    if (_currentDetailViewController) {
        [self removeCurrentDetailViewController];
    }

    [self addChildViewController:controller];
    controller.view.frame = [self frameForDetailViewController];
    [_detailView addSubview:controller.view];
    _currentDetailViewController = controller;
    [controller didMoveToParentViewController:self];
}

- (void)swapCurrentControllerWith:(UIViewController*)viewController{
    [_currentDetailViewController willMoveToParentViewController:nil];
    [self addChildViewController:viewController];
    viewController.view.frame = CGRectMake(0, 1000, viewController.view.frame.size.width, viewController.view.frame.size.height);
    [self.detailView addSubview:viewController.view];
    [UIView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseInOut
         animations:^{
             viewController.view.frame = _currentDetailViewController.view.frame;
             _currentDetailViewController.view.frame = CGRectMake(0,
                     -400,
                     _currentDetailViewController.view.frame.size.width,
                     _currentDetailViewController.view.frame.size.width);
             _currentDetailViewController.view.alpha = 0.0f;
         }
         completion:^(BOOL finished) {
             [_currentDetailViewController.view removeFromSuperview];
             [_currentDetailViewController removeFromParentViewController];
             _currentDetailViewController = viewController;
             [_currentDetailViewController didMoveToParentViewController:self];
         }];
}

- (void)removeCurrentDetailViewController {
    [_currentDetailViewController willMoveToParentViewController:nil];
    [_currentDetailViewController.view removeFromSuperview];
    [_currentDetailViewController removeFromParentViewController];
}

- (CGRect)frameForDetailViewController {
    return _detailView.bounds;
}

@end
