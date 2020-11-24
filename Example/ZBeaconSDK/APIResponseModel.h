// To parse this JSON:
//
//   NSError *error;
//   APIResponse *response = [APIResponse fromJSON:json encoding:NSUTF8Encoding error:&error];

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@class APIResponseModel;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface APIResponseModel : JSONModel

@property (nonatomic) NSInteger errorCode;
@property (nonatomic) NSString *errorMessage;
@property (nonatomic) NSDictionary *data;

@end

NS_ASSUME_NONNULL_END
