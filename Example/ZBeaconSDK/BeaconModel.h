// To parse this JSON:
//
//   NSError *error;
//   APIBeaconModel *beaconModel = [APIBeaconModel fromJSON:json encoding:NSUTF8Encoding error:&error];

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@class BeaconModel;
@class Monitor;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface BeaconModel : JSONModel

@property (nonatomic) NSString *identifier;
@property (nonatomic) double distance;
@property (nonatomic) Monitor *monitor;

@end

@interface Monitor : JSONModel

@property (nonatomic) BOOL isEnable;
@property (nonatomic) double movingRange;

@end

NS_ASSUME_NONNULL_END
