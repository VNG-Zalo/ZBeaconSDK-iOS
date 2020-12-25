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
- (void)onRangeBeacons:(NSArray<ZBeacon *> *_Nullable) beacons;


/**
 * onBeaconConnected:
 *
 * Discussion:
 *   Invoked when the device connects to a beacon.
 */
- (void)onBeaconConnected:(ZBeacon *_Nullable)beacon;

/**
 * onBeaconDisconnected:
 *
 * Discussion:
 *   Invoked when the device disconnects to a beacon.
 */
- (void)onBeaconDisconnected:(ZBeacon *_Nullable) beacon;

/**
 * onErrorWithErrorCode:errorMessage:
 *
 * Discussion:
 *   Invoked when receive an error
 */
- (void)onErrorWithErrorCode:(NSInteger) errorCode errorMessage:(NSString *_Nullable) errorMessage;


@end
