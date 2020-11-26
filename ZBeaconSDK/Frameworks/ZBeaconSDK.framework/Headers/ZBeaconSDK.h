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

+ (void) setLogLevel: (ZBeaconLogLevel) logLevel;
+(instancetype)sharedInstance;

@property(weak, nonatomic, nullable) id<ZBeaconSDKDelegate> delegate;
@property(assign, nonatomic) BOOL enableExtendBackgroundRunningTime;

- (NSString *)getVersion;
- (void)setListBeacons:(NSArray<NSString*> *) beacons;
- (void)startBeaconsWithCompletion:(void(^)(void))callback;
- (void)stopBeacons;

@end

NS_ASSUME_NONNULL_END
