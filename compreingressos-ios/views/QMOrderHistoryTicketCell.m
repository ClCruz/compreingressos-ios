//
//  QMOrderHistoryTicketCell.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 4/14/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "UIImage+MDQRCode.h"
#import "QMTicket.h"
#import "QMOrderHistoryTicketCell.h"

@implementation QMOrderHistoryTicketCell {
    @private
    QMTicket *_ticket;
    IBOutlet UILabel *_placeLabel;
    IBOutlet UIImageView *_qrcodeImageView;
}

@synthesize ticket = _ticket;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setTicket:(QMTicket *)ticket {
    _ticket = ticket;
    
    [_placeLabel setText:_ticket.place];
    CGFloat imageSize = _qrcodeImageView.bounds.size.width;
    [_qrcodeImageView setImage:[UIImage mdQRCodeForString:_ticket.qrcodeString size:imageSize fillColor:[UIColor blackColor]]];
    [_qrcodeImageView layoutIfNeeded];
    [_qrcodeImageView layoutSubviews];
}

@end