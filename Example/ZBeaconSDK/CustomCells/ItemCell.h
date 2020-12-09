//
//  ItemCell.h
//  ZBeaconSDK_Example
//
//  Created by ToanTM on 11/13/20.
//  Copyright © 2020 VNG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <ZBeaconSDK/ZBeaconSDK.h>
#import "PromotionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblUUID;
@property (weak, nonatomic) IBOutlet UILabel *lblMajor;
@property (weak, nonatomic) IBOutlet UILabel *lblMinor;
@property (weak, nonatomic) IBOutlet UILabel *lblRSSI;
@property (weak, nonatomic) IBOutlet UILabel *lblPromotion;
@property (weak, nonatomic) IBOutlet UIView *viewDisable;

@property (weak, nonatomic) ZBeacon *beacon;
@property (weak, nonatomic) PromotionModel *promotionModel;
@property (strong, nonatomic) NSString *currentBeaconUUID;

- (void)refreshInformation;

@end

NS_ASSUME_NONNULL_END
