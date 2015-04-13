//
//  QMOrderHistoryViewController.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 4/13/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMOrder.h"
#import "QMOrderHistoryCell.h"
#import "QMOrderHistoryViewController.h"


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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    
}


@end
