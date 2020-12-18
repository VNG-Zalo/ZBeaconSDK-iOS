//
//  ZRegion.h
//  ZBeaconSDK
//
//  Created by ToanTM on 17/12/2020.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZRegion : NSObject

/*
 *  initWithUUID:
 *
 *  Discussion:
 *    Initialize a ZRegion with a UUID. Major and minor values will be wildcarded.
 *
 */
- (instancetype)initWithUUID:(NSUUID *)uuid;

/*
 *  initWithUUID:major:
 *
 *  Discussion:
 *    Initialize a ZRegion with a UUID and major value. Minor value will be wildcarded.
 *
 */
- (instancetype)initWithUUID:(NSUUID *)uuid major:(NSNumber *_Nullable)major;

/*
 *  initWithUUID:major:minor:
 *
 *  Discussion:
 *    Initialize a ZRegion identified by a UUID, major and minor values.
 *
 */
- (instancetype)initWithUUID:(NSUUID *)uuid major:(NSNumber *_Nullable)major minor:(NSNumber *_Nullable)minor;

/*
 *  asRegion:
 *
 *  Discussion:
 *    Create a CLBeaconRegion from UUID, major and minor.
 *
 */
- (CLBeaconRegion*)asRegion;

@end

NS_ASSUME_NONNULL_END
