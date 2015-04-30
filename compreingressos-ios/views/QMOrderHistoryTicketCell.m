//
//  QMOrderHistoryTicketCell.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 4/14/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

//#import "UIImage+MDQRCode.h"
#import "QMTicket.h"
#import "QMOrderHistoryTicketCell.h"
#import "ZXImage.h"
#import "ZXMultiFormatWriter.h"

@implementation QMOrderHistoryTicketCell {
    @private
    QMTicket *_ticket;
    IBOutlet UILabel *_placeLabel;
    IBOutlet UIImageView *_qrcodeImageView;
    IBOutlet UILabel *_typeLabel;
    IBOutlet UILabel *_priceLabel;
}

@synthesize ticket = _ticket;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setTicket:(QMTicket *)ticket {
    _ticket = ticket;
    [_placeLabel setText:_ticket.place];
    [_priceLabel setText:[NSString stringWithFormat:@"R$ %@", _ticket.price]];
    [_typeLabel  setText:_ticket.type];
    
    
    NSString *data = _ticket.qrcodeString;
    if (data == 0) return;
    
    ZXMultiFormatWriter *writer = [[ZXMultiFormatWriter alloc] init];
    ZXBitMatrix *result = [writer encode:data
                                  format:kBarcodeFormatAztec
                                   width:300.0
                                  height:300.0
                                   error:nil];
    
    if (result) {
        ZXImage *image = [ZXImage imageWithMatrix:result];
        _qrcodeImageView.image = [UIImage imageWithCGImage:image.cgimage];
    } else {
        _qrcodeImageView.image = nil;
    }
    
    [_qrcodeImageView layoutIfNeeded];
    [_qrcodeImageView layoutSubviews];
}

- (IBAction)clickedOnAddToPassbook:(id)sender {
    [_ticket addToPassbook];
}

@end
