//
//  QMOrderDetailViewController.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 4/13/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "UIImage+MDQRCode.h"
#import "QMOrder.h"
#import "QMTicket.h"
#import "QMOrderDetailViewController.h"
#import "QMOrderDetailHeaderCell.h"

@interface QMOrderDetailViewController ()

@end

@implementation QMOrderDetailViewController {
@private
    QMOrder *_order;
    IBOutlet UITableView *_tableView;
}

@synthesize order = _order;

- (void)viewDidLoad {
    [super viewDidLoad];
    QMTicket *ingresso = _order.tickets[0];
    NSLog(@"qrcode: %@", ingresso.qrcodeString);
    
//    [self.navigationItem setTitle:[_order spectacleTitle]];
    
    
//    CGFloat imageSize = 150.0f;
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((320.0f - imageSize) / 2.0f, 100.0f, imageSize, imageSize)];
//    [self.view addSubview:imageView];
//    [imageView setImage:[UIImage mdQRCodeForString:ingresso.qrcodeString size:imageSize fillColor:[UIColor blackColor]]];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QMOrderDetailHeaderCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"QMOrderDetailHeaderCell" forIndexPath:indexPath];
    [cell setOrder:_order];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


@end
