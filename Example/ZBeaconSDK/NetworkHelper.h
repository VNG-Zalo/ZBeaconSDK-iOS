//
//  NetworkHelper.h
//  ZBeaconSDK_Example
//
//  Created by ToanTM on 23/11/2020.
//  Copyright © 2020 minhtoantm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BeaconPromotion.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetworkHelper : NSObject

+ (instancetype)sharedInstance;

- (void)getMasterBeaconUUIDList:(void(^)(NSArray<NSString *> *_Nullable uuids))callback;
- (void)getBeaconListForMasterBeaconUUID:(NSString *)uuidString callback:(void(^)(NSArray *_Nullable beaconModels)) callback;
- (void)getPromotionForBeaconUUID:(NSString *)uuidString callback:(void(^)(BeaconPromotion *_Nullable beaconPromotion)) callback;
- (void)submitConnectedBeacons:(NSArray *)beacons callback:(void(^)(NSError *_Nullable error)) callback;
- (void)submitConnectedAndMonitorBeacons:(NSArray *)beacons callback:(void(^)(NSError *_Nullable error)) callback;

@end

NS_ASSUME_NONNULL_END
