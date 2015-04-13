//
//  QMOrderHistoryCell.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 4/13/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMOrder.h"
#import "QMEspetaculo.h"
#import "QMOrderHistoryCell.h"

@implementation QMOrderHistoryCell {
    @private
    IBOutlet UILabel *_spectacleLabel;
    IBOutlet UILabel *_dateLabel;
    IBOutlet UILabel *_orderNumberLabel;
    QMOrder *_order;
}

@synthesize order = _order;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setOrder:(QMOrder *)order {
    _order = order;
    [_spectacleLabel setText:order.espetaculo.titulo];
    [_dateLabel setText:[order formattedDateAndHour]];
    [_orderNumberLabel setText:[order formattedOrderNumber]];
}

@end
