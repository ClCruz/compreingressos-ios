//
//  QMOrderHistoryViewController.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 4/13/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMConstants.h"
#import "QMOrder.h"
#import "QMOrderHistoryCell.h"
#import "QMOrderHistoryViewController.h"
#import "QMOrderDetailViewController.h"
#import "QMOrdersRequester.h"
#import "QMUser.h"
#import "SVProgressHUD.h"
#import <Google/Analytics.h>


@interface QMOrderHistoryViewController ()

@end

@implementation QMOrderHistoryViewController {
    @private
    IBOutlet UITableView *_tableView;
    UIRefreshControl *_refreshControl;
    NSArray *_orders;
    BOOL _firstViewDidAppear;
    IBOutlet UIView *_placeholder;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    _refreshControl = [[UIRefreshControl alloc] init];
    [_tableView addSubview:_refreshControl];
    [_refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    _placeholder.alpha = 0.0;
    [_placeholder removeFromSuperview];
    _firstViewDidAppear = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideBadgeTag
                                                        object:self
                                                      userInfo:nil];
    if (_firstViewDidAppear) {
        _orders = [QMOrder orderHistory];
        [self requestData];
        //[self sortOrdersBySentTime];
        [_tableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self deselectAnyRowIfNeeded];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Meus Ingressos"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)deselectAnyRowIfNeeded {
    NSIndexPath *selectedRow = [_tableView indexPathForSelectedRow];
    if (selectedRow) {
        [_tableView deselectRowAtIndexPath:selectedRow animated:NO];
    }
}

/* Utilizado pelo pull to refresh */
- (void)refreshTable {
    // [_tableView reloadData];
    [self requestData];
}

- (void)requestData {
    //if ([self isConnected]) {
        [self requestOrders];
    //} else {
    //    [self showPlaceholderIfNeeded];
    //    [self showNotConnectedErrorWithoutCover];
        [_refreshControl endRefreshing];
   //}
}

- (void)requestOrders {
    QMUser *user = [QMUser sharedInstance];
    if ([user hasHash]) {
        if (_firstViewDidAppear) {
            [SVProgressHUD show];
        }
        [QMOrdersRequester requestOrdersForUser:[QMUser sharedInstance] onCompleteBlock:^(NSArray *orders) {
            _orders = [QMOrder sortOrdersByOrderNumber:orders];
            //[self showPlaceholderIfNeeded];
            //[self sortOrdersBySentTime];
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            [_refreshControl endRefreshing];
            [QMOrder setOrderHistory:_orders];
            [SVProgressHUD dismiss];
            _firstViewDidAppear = NO;
        } onFailBlock:^(NSError *error) {
            [_refreshControl endRefreshing];
            [SVProgressHUD dismiss];
            _firstViewDidAppear = NO;
        }];
    } else {
        [self showPlaceholder];
    }
}

- (void)showPlaceholder {
    [_placeholder setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_tableView addSubview:_placeholder];
    NSLayoutConstraint *width =[NSLayoutConstraint
            constraintWithItem:_placeholder
                     attribute:NSLayoutAttributeWidth
                     relatedBy:0
                        toItem:_tableView
                     attribute:NSLayoutAttributeWidth
                    multiplier:1.0
                      constant:0];
    NSLayoutConstraint *height =[NSLayoutConstraint
            constraintWithItem:_placeholder
                     attribute:NSLayoutAttributeHeight
                     relatedBy:0
                        toItem:_tableView
                     attribute:NSLayoutAttributeHeight
                    multiplier:1.0
                      constant:0];
    NSLayoutConstraint *top = [NSLayoutConstraint
            constraintWithItem:_placeholder
                     attribute:NSLayoutAttributeTop
                     relatedBy:NSLayoutRelationEqual
                        toItem:_tableView
                     attribute:NSLayoutAttributeTop
                    multiplier:1.0f
                      constant:0.f];
    NSLayoutConstraint *leading = [NSLayoutConstraint
            constraintWithItem:_placeholder
                     attribute:NSLayoutAttributeLeading
                     relatedBy:NSLayoutRelationEqual
                        toItem:_tableView
                     attribute:NSLayoutAttributeLeading
                    multiplier:1.0f
                      constant:0.f];

    [_tableView addConstraints:@[width, height, top, leading]];
    
    [UIView animateWithDuration:0.3 animations:^{
        _placeholder.alpha = 1.0;
    }];
}

#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self configureNextViewBackButtonWithTitle:@"Voltar"];
    QMOrderDetailViewController *controller = segue.destinationViewController;
    [controller setOrder:(QMOrder *)sender];
    [super prepareForSegue:segue sender:sender];
}

- (void)configureNextViewBackButtonWithTitle:(NSString *)title {
    UIBarButtonItem *nextViewBackButton = [[UIBarButtonItem alloc] initWithTitle:title
                                                                           style:UIBarButtonItemStyleDone
                                                                          target:nil
                                                                          action:nil];
    [self.navigationItem setBackBarButtonItem:nextViewBackButton];
}

#pragma mark - 
#pragma mark - TableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_orders count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QMOrderHistoryCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"QMOrderHistoryCell" forIndexPath:indexPath];
    QMOrder *order = _orders[(NSUInteger)indexPath.row];
    [cell setOrder:order];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QMOrder *order = _orders[(NSUInteger)indexPath.row];
    [self performSegueWithIdentifier:@"orderDetailSegue" sender:order];
}


@end
