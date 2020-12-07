//
//  ZBeacon.h
//  ZBeaconSDK
//
//  Created by ToanTM on 19/11/2020.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZBeacon : NSObject {
    
}

/*
 *  UUID
 *
 *  Discussion:
 *    UUID associated with the beacon.
 *
 */
@property (readonly, nonatomic, copy) NSUUID *UUID;

/*
 *  major
 *
 *  Discussion:
 *    Most significant value associated with the beacon.
 *
 */
@property (readonly, nonatomic, copy) NSNumber *major;

/*
 *  minor
 *
 *  Discussion:
 *    Least significant value associated with the beacon.
 *
 */
@property (readonly, nonatomic, copy) NSNumber *minor;

/*
 *  proximity
 *
 *  Discussion:
 *    Proximity of the beacon from the device.
 *
 */
@property (readonly, nonatomic) CLProximity proximity;

/*
 *  accuracy
 *
 *  Discussion:
 *    Represents an one sigma horizontal accuracy in meters where the measuring device's location is
 *    referenced at the beaconing device. This value is heavily subject to variations in an RF environment.
 *    A negative accuracy value indicates the proximity is unknown.
 *
 */
@property (readonly, nonatomic) CLLocationAccuracy accuracy;

/*
 *  distance
 *
 *  Discussion:
 *    Distance in meters from the device to the beacon. This value is heavily subject to variations in an RF environment.
 *    A zero distance value indicates the proximity is unknown.
 *
 */
@property (readonly, nonatomic) double distance;

/*
 *  rssi
 *
 *  Discussion:
 *    Received signal strength in decibels of the specified beacon.
 *    This value is an average of the RSSI samples collected since this beacon was last reported.
 *
 */
@property (readonly, nonatomic) NSInteger rssi;

/*
 *  lastTimeReceiveSignal
 *
 *  Discussion:
 *    Last time received sigal from the beacon.
 *
 */
@property (readonly, nonatomic, copy, nullable) NSDate *lastTimeReceiveSignal;

/*
 *  locationString
 *
 *  Discussion:
 *    From proximity and accuracy value, display in human value for easy to reading when debug or logging.
 *
 */
- (NSString* )locationString;

/*
 *  nameForProximity
 *
 *  Discussion:
 *    From proximity value, convert to string value. Using for debug or logging.
 *
 */
- (NSString* )nameForProximity;

/*
 *  debugDescription
 *
 *  Discussion:
 *    Debug description of object.
 *
 */
- (NSString* )debugDescription;

@end

NS_ASSUME_NONNULL_END
