// To parse this JSON:
//
//   NSError *error;
//   QBeaconPromotion *beaconPromotion = [QBeaconPromotion fromJSON:json encoding:NSUTF8Encoding error:&error];

#import <Foundation/Foundation.h>

@class BeaconPromotion;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface BeaconPromotion : NSObject
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *banner;
@property (nonatomic, copy) NSString *theDescription;

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error;
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
- (NSData *_Nullable)toData:(NSError *_Nullable *)error;
@end

NS_ASSUME_NONNULL_END
