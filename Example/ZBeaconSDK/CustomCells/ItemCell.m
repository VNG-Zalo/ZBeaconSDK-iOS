//
//  ItemCell.m
//  ZBeaconSDK_Example
//
//  Created by ToanTM on 11/13/20.
//  Copyright © 2020 VNG. All rights reserved.
//

#import "ItemCell.h"

@implementation ItemCell



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setBeacon:(ZBeacon *)beacon {
    _beacon = beacon;
    if (_beacon) {
        _lblUUID.text = _beacon.UUID.UUIDString;
        _lblMajor.text = [_beacon.major stringValue];
        _lblMinor.text = [_beacon.minor stringValue];
    } else {
        _lblUUID.text = @"N/A";
        _lblMajor.text = @"N/A";
        _lblMinor.text = @"N/A";
    }
}

- (void)refreshInformation {
    
    if (_beacon) {
        _lblLocation.text = [_beacon locationString];
        _lblRSSI.text = [@(_beacon.rssi) stringValue];
    } else {
        _lblLocation.text = @"Unknown";
        _lblRSSI.text = @"N/A";
    }
    
    if (_promotionModel) {
        _lblName.text = _promotionModel.banner;
        _lblPromotion.text = _promotionModel.theDescription;
    } else {
        _lblName.text = @"Unknown";
        _lblPromotion.text = @"Unknown";
    }
}

@end
