//
//  ItemCell.m
//  ZBeaconSDK_Example
//
//  Created by ToanTM on 11/13/20.
//  Copyright © 2020 VNG. All rights reserved.
//

#import "ItemCell.h"

@interface ItemCell()


@end

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
        if (_currentBeaconUUID) {
            _lblUUID.text = _currentBeaconUUID;
        } else {
            _lblUUID.text = @"N/A";
        }
        _lblMajor.text = @"N/A";
        _lblMinor.text = @"N/A";
    }
}

- (void)refreshInformation {
    
    if (_beacon) {
        _lblLocation.text = [NSString stringWithFormat:@"Distance: (approx. %.2f m)", _beacon.distance];
        _lblRSSI.text = [@(_beacon.rssi) stringValue];
    } else {
        if (_currentBeaconUUID && _currentBeaconUUID.length > 0) {
            _lblLocation.text = @"Disconnected";
        } else {
            _lblLocation.text = @"Unknown";
        }
        _lblRSSI.text = @"N/A";
    }
    
    _lblName.text = (_beaconName && _beaconName.length > 0) ? _beaconName : @"Unknown";
    _lblPromotion.text = (_beaconPromotion && _beaconPromotion.length > 0) ? _beaconPromotion : @"Unknown";
}

@end
