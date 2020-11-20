//
//  ZBeacon.h
//  ZBeaconSDK
//
//  Created by ToanTM on 19/11/2020.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZBeacon : NSObject

@property (readonly, nonatomic, copy) NSUUID *UUID;
@property (readonly, nonatomic, copy) NSNumber *major;
@property (readonly, nonatomic, copy) NSNumber *minor;
@property (readonly, nonatomic) CLProximity proximity;
@property (readonly, nonatomic) CLLocationAccuracy accuracy;
@property (readonly, nonatomic) NSInteger rssi;

- (NSString* )locationString;
- (NSString* )nameForProximity;
- (NSString* )debugDescription;

@end

NS_ASSUME_NONNULL_END
