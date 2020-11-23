// To parse this JSON:
//
//   NSError *error;
//   APIBeaconModel *beaconModel = [APIBeaconModel fromJSON:json encoding:NSUTF8Encoding error:&error];

#import <Foundation/Foundation.h>

@class BeaconModel;
@class Monitor;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface BeaconModel : NSObject
@property (nonatomic, copy)   NSString *identifier;
@property (nonatomic, assign) double distance;
@property (nonatomic, strong) Monitor *monitor;

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error;
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
- (NSData *_Nullable)toData:(NSError *_Nullable *)error;
@end

@interface Monitor : NSObject
@property (nonatomic, assign) BOOL isEnable;
@property (nonatomic, assign) double movingRange;
@end

NS_ASSUME_NONNULL_END
