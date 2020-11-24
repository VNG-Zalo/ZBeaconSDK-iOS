// To parse this JSON:
//
//   NSError *error;
//   APIBeaconModel *beaconModel = [APIBeaconModel fromJSON:json encoding:NSUTF8Encoding error:&error];

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@class BeaconModel;
@class MonitorModel;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface BeaconModel : JSONModel

@property (nonatomic) NSString *identifier;
@property (nonatomic) double distance;
@property (nonatomic) MonitorModel *monitor;

@end

@interface MonitorModel : JSONModel

@property (nonatomic) BOOL isEnable;
@property (nonatomic) double movingRange;

@end

NS_ASSUME_NONNULL_END
