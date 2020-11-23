//
//  NetworkHelper.h
//  ZBeaconSDK_Example
//
//  Created by ToanTM on 23/11/2020.
//  Copyright © 2020 minhtoantm. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkHelper : NSObject

+ (instancetype)sharedInstance;

- (void)getMasterBeaconUUIDList:(void(^)(NSArray<NSString *> *uuids))callback;
- (void)getBeaconListForMasterBeaconUUID:(NSString *)uuidString callback:(void(^)(NSArray *beaconModels)) callback;

@end

NS_ASSUME_NONNULL_END
