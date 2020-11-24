// To parse this JSON:
//
//   NSError *error;
//   QBeaconPromotion *beaconPromotion = [QBeaconPromotion fromJSON:json encoding:NSUTF8Encoding error:&error];

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@class BeaconPromotion;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface BeaconPromotion : JSONModel
@property (nonatomic) NSString *link;
@property (nonatomic) NSString *banner;
@property (nonatomic) NSString *theDescription;

@end

NS_ASSUME_NONNULL_END
