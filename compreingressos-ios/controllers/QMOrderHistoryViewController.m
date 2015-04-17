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


@interface QMOrderHistoryViewController ()

@end

@implementation QMOrderHistoryViewController {
    @private
    IBOutlet UITableView *_tableView;
    NSArray *_orderHistory;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _orderHistory = [QMOrder orderHistory];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideBadgeTag
                                                        object:self
                                                      userInfo:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [_orderHistory count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QMOrderHistoryCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"QMOrderHistoryCell" forIndexPath:indexPath];
    QMOrder *order = _orderHistory[(int)indexPath.row];
    [cell setOrder:order];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QMOrder *order = _orderHistory[(int)indexPath.row];
    [self performSegueWithIdentifier:@"orderDetailSegue" sender:order];
}


@end
