//
//  CacheHelper.m
//  ZBeaconSDK_Example
//
//  Created by ToanTM on 07/12/2020.
//  Copyright © 2020 VNG. All rights reserved.
//

#import "CacheHelper.h"

#define USER_DEFAULT_KEY_MASTER_UUIDS       @"USER_DEFAULT_KEY_MASTER_UUIDS"
#define USER_DEFAULT_KEY_CLIENT_BEACON      @"USER_DEFAULT_KEY_CLIENT_BEACON_"
#define USER_DEFAULT_KEY_MONITOR_INTERVAL   @"USER_DEFAULT_KEY_MONITOR_INTERVAL"
#define USER_DEFAULT_KEY_EXPIRED_TIME_OF_CLIENT_BEACON  @"USER_DEFAULT_KEY_EXPIRED_TIME_OF_CLIENT_BEACON"

@implementation CacheHelper

+ (instancetype)sharedInstance {
    static id __sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[CacheHelper alloc] init];
    });
    
    return __sharedInstance;
}

- (void)saveMasterUUIDs:(NSArray<NSString *> *)uuids {
    [[NSUserDefaults standardUserDefaults] setObject:uuids forKey:USER_DEFAULT_KEY_MASTER_UUIDS];
}

- (NSArray<NSString *> *)getMasterUUIDs {
    NSMutableArray *ret = nil;
    
    ret = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_MASTER_UUIDS];
    
    return ret;
}

- (void)saveClientBeaconModels:(NSArray<BeaconModel *> *)beaconModels ofMasterUUID:(NSString *)masterUUID {
    NSString *key = [NSString stringWithFormat:@"%@%@", USER_DEFAULT_KEY_CLIENT_BEACON, masterUUID];
    NSArray *data = [BeaconModel arrayOfDictionariesFromModels:beaconModels];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
}

- (NSArray<BeaconModel *> *)getClientBeaconModelsOfMasterUUID:(NSString *)masterUUID {
    NSString *key = [NSString stringWithFormat:@"%@%@", USER_DEFAULT_KEY_CLIENT_BEACON, masterUUID];
    NSArray *dicts = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    NSError *error;
    NSArray *ret = [BeaconModel arrayOfModelsFromDictionaries:dicts error:&error];
    if (error) {
        NSLog(@"%s: %@", __func__, error);
    }
    return ret;
}

- (void)saveMonitorInterval:(NSTimeInterval)interval {
    [[NSUserDefaults standardUserDefaults] setDouble:interval forKey:USER_DEFAULT_KEY_MONITOR_INTERVAL];
}

- (NSTimeInterval)getMonitorInterval {
    NSTimeInterval ret = [[NSUserDefaults standardUserDefaults] doubleForKey:USER_DEFAULT_KEY_MONITOR_INTERVAL];
    return ret;
}

- (void)saveExpiredTimeOfClientBeacon:(NSTimeInterval)interval {
    [[NSUserDefaults standardUserDefaults] setDouble:interval forKey:USER_DEFAULT_KEY_EXPIRED_TIME_OF_CLIENT_BEACON];
}

- (NSTimeInterval)getExpiredTimeOfClientBeacon {
    NSTimeInterval ret = [[NSUserDefaults standardUserDefaults] doubleForKey:USER_DEFAULT_KEY_EXPIRED_TIME_OF_CLIENT_BEACON];
    return ret;
}

@end
