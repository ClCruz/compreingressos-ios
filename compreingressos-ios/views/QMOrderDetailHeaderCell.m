//
//  QMOrderDetailHeaderCell.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 4/14/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMOrder.h"
#import "QMEspetaculo.h"
#import "QMOrderDetailHeaderCell.h"

@implementation QMOrderDetailHeaderCell {
    @private
    QMOrder *_order;
    IBOutlet UILabel *_addressLabel;
    IBOutlet UILabel *_dateAndHourLabel;
    IBOutlet UILabel *_titleLabel;
}

@synthesize order = _order;

- (void)awakeFromNib {

}

- (void)setOrder:(QMOrder *)order {
    _order = order;
    [_titleLabel setText:[_order spectacleTitle]];
    [_addressLabel setText:_order.espetaculo.endereco];
    [_dateAndHourLabel setText:[_order formattedDateAndHour]];
}


@end
