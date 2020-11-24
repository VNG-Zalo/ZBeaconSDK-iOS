#import "BeaconModel.h"

NS_ASSUME_NONNULL_BEGIN

@implementation BeaconModel

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"identifier": @"id",
    }];
}

@end

@implementation Monitor

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"isEnable": @"enable",
        @"movingRange": @"moving_range",
    }];
}

@end

NS_ASSUME_NONNULL_END
