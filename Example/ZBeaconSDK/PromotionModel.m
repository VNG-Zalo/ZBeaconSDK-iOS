#import "PromotionModel.h"

NS_ASSUME_NONNULL_BEGIN

@implementation PromotionModel

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"theDescription": @"description"
    }];
}

@end

NS_ASSUME_NONNULL_END
