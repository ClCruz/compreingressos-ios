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
    IBOutlet UILabel *_titleLabel;
    IBOutlet UILabel *_theaterLabel;
    IBOutlet UILabel *_monthLabel;
    IBOutlet UILabel *_dayLabel;
    IBOutlet UILabel *_weekdayLabel;
}

@synthesize order = _order;

- (void)awakeFromNib {

}

- (void)setOrder:(QMOrder *)order {
    _order = order;
    [_titleLabel setText:[_order spectacleTitle]];
    [_theaterLabel setText:_order.espetaculo.teatro];
    [_addressLabel setText:_order.espetaculo.endereco];
    
    NSArray *components = [_order.date componentsSeparatedByString:@" "];
    if ([components count] >= 1) {
        NSString *weekdayString = [((NSString *)components[0]) uppercaseString];
        [_weekdayLabel setText:weekdayString];
    }
    if ([components count] >= 2) {
        [_dayLabel setText:components[1]];
    }
    if ([components count] >= 3) {
        NSString *monthString = [((NSString *)components[2]) uppercaseString];
        [_monthLabel setText:monthString];
    }
//    [_dateAndHourLabel setText:[_order formattedDateAndHour]];
}


@end
