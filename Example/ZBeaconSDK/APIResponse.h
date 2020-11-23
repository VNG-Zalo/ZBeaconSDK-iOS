// To parse this JSON:
//
//   NSError *error;
//   APIResponse *response = [APIResponse fromJSON:json encoding:NSUTF8Encoding error:&error];

#import <Foundation/Foundation.h>

@class APIResponse;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface APIResponse : NSObject
@property (nonatomic, assign) NSInteger errorCode;
@property (nonatomic, copy)   NSString *errorMessage;
@property (nonatomic, strong) NSDictionary *data;

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error;
- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
- (NSData *_Nullable)toData:(NSError *_Nullable *)error;
@end

NS_ASSUME_NONNULL_END
