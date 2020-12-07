//
//  ZBeaconSDK.h
//  ZBeaconSDK
//
//  Created by ToanTM on 11/13/20.
//

#import <Foundation/Foundation.h>
#import "ZBeaconSDKDelegate.h"
#import "ZBeacon.h"
#import "ZBeaconLogManager.h"


NS_ASSUME_NONNULL_BEGIN

@interface ZBeaconSDK : NSObject


/// Set log level of SDK.
/// @param logLevel ZBeaconLogLevel.
+ (void) setLogLevel: (ZBeaconLogLevel) logLevel;


/// Singleton object of SDK.
+(instancetype)sharedInstance;


/// Delegate of SDK.
@property(weak, nonatomic, nullable) id<ZBeaconSDKDelegate> delegate;



///Using to extend your app’s background execution time. Default value is NO.
@property(assign, nonatomic) BOOL enableExtendBackgroundRunningTime;


/// Enable handle timeout for beacon.
@property(assign, nonatomic) BOOL enableBeaconTimeout;

/// Beacon timeout interval
@property (nonatomic, assign) NSTimeInterval beaconTimeOutInterval;

/// Get SDK version.
- (NSString *)getVersion;


/// Set UUID list.
/// @param beacons UUID list.
- (void)setListBeacons:(NSArray<NSString*> *) beacons;

/// Start monitoring and ranging beacons what are created from UUID list in setListBeacons method.
/// @param callback completed callback.
- (void)startBeaconsWithCompletion:(void(^)(void))callback;

/// Stop monitoring and ranging all beacons.
- (void)stopBeacons;

@end

NS_ASSUME_NONNULL_END
