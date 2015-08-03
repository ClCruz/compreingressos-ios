//
//  QMOrderDetailViewController.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 4/13/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//


#import "QMOrder.h"
#import "QMTicket.h"
#import "QMConstants.h"
#import "QMOrderDetailViewController.h"
#import "QMOrderDetailHeaderCell.h"
#import "QMOrderHistoryTicketCell.h"
#import "QMOrderDetailLocatorCell.h"
#import <Google/Analytics.h>

@interface QMOrderDetailViewController ()

@end

@implementation QMOrderDetailViewController {
@private
    BOOL     _isModal;
    QMOrder *_order;
    UINavigationBar *_navigationBarForModal;
    IBOutlet UITableView *_tableView;
}

@synthesize order = _order;
@synthesize isModal = _isModal;

- (void)viewDidLoad {
    [super viewDidLoad];
    QMTicket *ingresso = _order.tickets[0];
    NSLog(@"qrcode: %@", ingresso.qrcodeString);
    
    if ([_order.tickets count] > 1) {
        [self.navigationItem setTitle:@"Ingressos"];
    } else {
        [self.navigationItem setTitle:@"Ingresso"];
    }
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self configureModalIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Detalhe Ingresso"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureModalIfNeeded {
    if (!_isModal) return;
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Fechar" style:UIBarButtonItemStyleDone target:self action:@selector(clickedOnCloseButton:)];
    [closeButton setTintColor:UIColorFromRGB(kCompreIngressosDefaultRedColor)];
    self.navigationItem.rightBarButtonItem = closeButton;
}

- (void)clickedOnCloseButton:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return 1 + [_order.tickets count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    int row = (int)indexPath.row;
    int section = (int)indexPath.section;

    if (section == 0) {
        QMOrderDetailLocatorCell *locatorCell = [_tableView dequeueReusableCellWithIdentifier:@"QMOrderDetailLocatorCell" forIndexPath:indexPath];
        [locatorCell.orderNumber setText:_order.number];
        cell = locatorCell;
    } else {
        if (row == 0) {
            QMOrderDetailHeaderCell *headerCell = [_tableView dequeueReusableCellWithIdentifier:@"QMOrderDetailHeaderCell" forIndexPath:indexPath];
            [headerCell setOrder:_order];
            cell = headerCell;
        } else {
            QMOrderHistoryTicketCell *ticketCell = [_tableView dequeueReusableCellWithIdentifier:@"QMOrderHistoryTicketCell" forIndexPath:indexPath];
            [self configureTicketCell:ticketCell forIndexPath:indexPath];
            cell = ticketCell;
        }
    }

    return cell;
}

- (void)configureTicketCell:(QMOrderHistoryTicketCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    int ticketIndex = (int)indexPath.row - 1;
    QMTicket *ticket = _order.tickets[(NSUInteger) ticketIndex];
    [cell setTicket:ticket];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *sizingCell = nil;
    int row = (int)indexPath.row;
    int section = (int)indexPath.section;
    
    if (section == 0) {
        return 30.0;
    } else {
        if (row == 0) {
            static QMOrderDetailHeaderCell *sizingHeaderCell = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                sizingHeaderCell = [_tableView dequeueReusableCellWithIdentifier:@"QMOrderDetailHeaderCell"];
            });
            [sizingHeaderCell setOrder:_order];
            sizingCell = sizingHeaderCell;
        } else {
            static QMOrderHistoryTicketCell *sizingTicketCell = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                sizingTicketCell = [_tableView dequeueReusableCellWithIdentifier:@"QMOrderHistoryTicketCell"];
            });
            [self configureTicketCell:sizingTicketCell forIndexPath:indexPath];
            sizingCell = sizingTicketCell;
        }
        [sizingCell setNeedsLayout];
        [sizingCell layoutIfNeeded];
        CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
        // NSLog(@"CELL SIZE: %@", NSStringFromCGSize(size));
        return size.height;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


@end
