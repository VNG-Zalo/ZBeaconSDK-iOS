//
//  CacheHelper.h
//  ZBeaconSDK_Example
//
//  Created by ToanTM on 07/12/2020.
//  Copyright © 2020 VNG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BeaconModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CacheHelper : NSObject

+ (instancetype)sharedInstance;

- (void)saveMasterUUIDs:(NSArray<NSString*>*) uuids;
- (NSArray<NSString*>*)getMasterUUIDs;
- (void)saveClientBeaconModels:(NSArray<BeaconModel*>*) beaconModels ofMasterUUID:(NSString*)masterUUID;
- (NSArray<BeaconModel*>*)getClientBeaconModelsOfMasterUUID:(NSString*)masterUUID;
- (void)saveMonitorInterval:(NSTimeInterval) interval;
- (NSTimeInterval)getMonitorInterval;
- (void)saveExpiredTimeOfClientBeacon:(NSTimeInterval) interval;
- (NSTimeInterval)getExpiredTimeOfClientBeacon;
- (void)saveTimeOutOfClientBeacon:(NSTimeInterval) interval;
- (NSTimeInterval)getTimeOutOfClientBeacon;

- (void)removeSubmitMonitorLog;
- (NSArray*)getSubmitMonitorLog;
- (void)saveSubmitMonitorLog:(NSArray*)items;

- (NSString*)getNameOfBeaconUUID:(NSString*)uuidString;
- (void)saveName:(NSString*)name ofBeaconUUID:(NSString*)uuidString;

@end

NS_ASSUME_NONNULL_END
