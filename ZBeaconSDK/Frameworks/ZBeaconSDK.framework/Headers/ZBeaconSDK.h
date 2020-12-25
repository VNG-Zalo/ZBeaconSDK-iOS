//
//  ZBeaconSDK.h
//  ZBeaconSDK
//
//  Created by ToanTM on 11/13/20.
//

#import <Foundation/Foundation.h>
#import "ZBeaconSDKDelegate.h"
#import "ZBeacon.h"
#import "ZRegion.h"
#import "ZBeaconLogManager.h"


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ZBeaconSDKErrorCode) {
    ZBeaconSDKErrorCodeSuccess = 0,
    ZBeaconSDKErrorCodeLocationNotAvaiable = -1,
    ZBeaconSDKErrorCodeLocationDenied = -2,
    ZBeaconSDKErrorCodeBluetoothNotAvaiable = -3
};

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


/// Enable handle timeout for beacon. Default value is NO.
@property(assign, nonatomic) BOOL enableBeaconTimeout;

/// Beacon timeout interval. Default value is 10 seconds.
@property (nonatomic, assign) NSTimeInterval beaconTimeOutInterval;

/// Get SDK version.
- (NSString *)getVersion;


/// Set ZRegion list.
/// @param regions region list.
- (void)setListBeacons:(NSArray<ZRegion*> *) regions;

/// Start monitoring and ranging beacons what are created from UUID list in setListBeacons method.
/// @param callback completed callback.
- (void)startBeaconsWithCompletion:(void(^)(NSInteger errorCode, NSString *_Nullable errorMessage))callback;

/// Stop monitoring and ranging all beacons.
- (void)stopBeacons;

@end

NS_ASSUME_NONNULL_END
