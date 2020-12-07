//
//  ZBeaconSDKDelegate.h
//  ZBeaconSDK
//
//  Created by ToanTM on 16/11/2020.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class ZBeacon;

@protocol ZBeaconSDKDelegate <NSObject>

/**
 * onRangeBeacons:
 *
 * Discussion:
 *   Invoked when receive rssi signal of beacons. Using this method to know distance from device to beacons.
 */
- (void)onRangeBeacons:(NSArray<ZBeacon *> *) beacons;


/**
 * onBeaconConnected:
 *
 * Discussion:
 *   Invoked when the device connects to a beacon.
 */
- (void)onBeaconConnected:(ZBeacon *)beacon;

/**
 * onBeaconConnected:
 *
 * Discussion:
 *   Invoked when the device disconnects to a beacon.
 */
- (void)onBeaconDisconnected:(ZBeacon *) beacon;


@end
