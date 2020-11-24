#import "APIResponse.h"

NS_ASSUME_NONNULL_BEGIN

@implementation APIResponse

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"errorCode": @"error_code",
        @"errorMessage": @"error_message",
    }];
}

@end

NS_ASSUME_NONNULL_END
