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

- (void)onRangeBeacons:(NSArray<ZBeacon *> *) beacons;
- (void)onBeaconConnected:(ZBeacon *)beacon;
- (void)onBeaconDisconnected:(ZBeacon *) beacon;


@end
