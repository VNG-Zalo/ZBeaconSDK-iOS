//
//  NetworkHelper.m
//  ZBeaconSDK_Example
//
//  Created by ToanTM on 23/11/2020.
//  Copyright © 2020 VNG. All rights reserved.
//

#import "NetworkHelper.h"
#import <AFNetworking/AFNetworking.h>
#import <ZBeaconSDK/ZBeaconSDK.h>
#import "APIResponseModel.h"
#import "BeaconModel.h"
#import <ZaloSDK/ZaloSDK.h>
#import "UIDevice+Extension.h"
#import "CacheHelper.h"

#define PLATFORM        @"2" // 1: android; 2: ios

@interface NetworkHelper ()

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;
@property (strong, nonatomic) NSString* appVersion;

@end

@implementation NetworkHelper

+ (instancetype)sharedInstance {
    static id __sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[NetworkHelper alloc] init];
    });
    
    return __sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURL *baseURL = [NSURL URLWithString:@"https://dev-zbeacon.zapps.vn"];
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        [_sessionManager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        
        _appVersion = [self getAppVersion];
        
    }
    return self;
}

#pragma mark Public Methods
- (void)getMasterBeaconUUIDList:(void (^)(NSArray<NSString *> * _Nullable, NSError * _Nullable))callback {
    
    NSDictionary *params = [self getBaseParams];
    
    [_sessionManager GET:@"getMasterBeacon"
              parameters:params
                progress:nil
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error;
        APIResponseModel *apiResponse = [[APIResponseModel alloc] initWithDictionary:responseObject error:&error];
        NSMutableArray *uuids = nil;
        if (error) {
            NSLog(@"error: %@", error);
        } else {
            if (apiResponse.errorCode != 0) {
                NSLog(@"getMasterBeaconUUIDList: errorCode=%ld errorMessage=%@", (long)apiResponse.errorCode, apiResponse.errorMessage);
            } else {
                NSArray *rawUUIDs = [((NSDictionary *)apiResponse.data) objectForKey:@"items"];
                uuids = [NSMutableArray new];
                for (NSString *uuid in rawUUIDs) {
                    [uuids addObject:[uuid uppercaseString]];
                }
            }
        }
        if (callback) {
            callback(uuids, error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"getMasterBeaconUUIDList error: %@", error);
        if (callback) {
            callback(nil, error);
        }
    }];
}

- (void)getBeaconListForMasterBeaconUUID:(NSString *)uuidString
                                callback:(void (^)(NSArray<BeaconModel *> * _Nullable, NSTimeInterval, NSTimeInterval, NSTimeInterval, NSString * _Nullable, NSError * _Nullable))callback {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[self getBaseParams]];
    if (uuidString && uuidString.length > 0) {
        params[@"bcid"] = uuidString;
    }
    
    [_sessionManager GET:@"getAroundHere"
              parameters:params
                progress:nil
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error;
        APIResponseModel *apiResponse = [[APIResponseModel alloc] initWithDictionary:responseObject error:&error];
        NSMutableArray *beaconModels = nil;
        NSInteger monitorInterval = 0;
        NSInteger expired = 0;
        NSInteger timeout = 0;
        NSString *nameOfMasterBeacon = nil;
        if (error) {
            NSLog(@"error: %@", error);
        } else {
            if (apiResponse.errorCode != 0) {
                NSLog(@"getBeaconListForMasterBeaconUUID: errorCode=%ld errorMessage=%@", (long)apiResponse.errorCode, apiResponse.errorMessage);
            } else {
                monitorInterval = [apiResponse.data[@"monitor_interval"] intValue];
                expired = [apiResponse.data[@"expire"] intValue];
                timeout = [apiResponse.data[@"time_out"] intValue];
                nameOfMasterBeacon = apiResponse.data[@"host"];
                
                NSLog(@"getBeaconListForMasterBeaconUUID: monitorInterval=%ld expired=%ld", (long)monitorInterval, (long)expired);
                NSArray *items = apiResponse.data[@"items"];
                beaconModels = [BeaconModel arrayOfModelsFromDictionaries:items error:&error];
                for (BeaconModel *beaconModel in beaconModels) {
                    beaconModel.identifier = [beaconModel.identifier uppercaseString];
                }
                if (error) {
                    NSLog(@"getBeaconListForMasterBeaconUUID error: %@", error);
                }
            }
        }
        if (callback) {
            callback(beaconModels, monitorInterval, expired, timeout, nameOfMasterBeacon, error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"getBeaconListForMasterBeaconUUID error: %@", error);
        if (callback) {
            callback(nil, 0, 0, 0, nil, error);
        }
    }];
}

- (void)getPromotionForBeaconUUID:(NSString *)uuidString
                         callback:(void (^)(PromotionModel * _Nullable, NSError * _Nullable))callback {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[self getBaseParams]];
    params[@"id"] = uuidString;
    [_sessionManager GET:@"promotion"
              parameters:params
                progress:nil
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error;
        APIResponseModel *apiResponse = [[APIResponseModel alloc] initWithDictionary:responseObject error:&error];
        PromotionModel *promotion = nil;
        if (error) {
            NSLog(@"error: %@", error);
        } else {
            if (apiResponse.errorCode != 0) {
                NSLog(@"getPromotionForBeaconUUID: errorCode=%ld errorMessage=%@", (long)apiResponse.errorCode, apiResponse.errorMessage);
                error = [NSError errorWithDomain:@"submitConnectedAndMonitorBeacons"
                                            code:apiResponse.errorCode
                                        userInfo:@{NSLocalizedDescriptionKey:apiResponse.errorMessage}];
            } else {
                NSError *error;
                promotion = [[PromotionModel alloc] initWithDictionary:apiResponse.data error:&error];
                if (error) {
                    NSLog(@"getPromotionForBeaconUUID error: %@", error);
                }
            }
        }
        if (callback) {
            callback(promotion, error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"getPromotionForBeaconUUID error: %@", error);
        if (callback) {
            callback(nil, error);
        }
    }];
}

- (void)submitConnectedBeacons:(NSArray *)beacons callback:(void (^)(NSError * _Nullable))callback {
    
    NSString *jsonString = [self convertZBeaconArrayToJsonString:beacons];
    
    NSDictionary *params = [self getBaseParams];
    NSString *path = [self addQueryStringToUrl:@"submit" params:params];
    [_sessionManager POST:path
               parameters:@{@"items": jsonString}
                 progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error;
        APIResponseModel *apiResponse = [[APIResponseModel alloc] initWithDictionary:responseObject error:&error];
        if (error) {
            NSLog(@"error: %@", error);
        } else {
            if (apiResponse.errorCode == 0) {
                error = nil;
            } else {
                error = [NSError errorWithDomain:@"submitConnectedBeacons"
                                            code:apiResponse.errorCode
                                        userInfo:@{NSLocalizedDescriptionKey:apiResponse.errorMessage}];
            }
        }
        if (callback) {
            callback(error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%s: %@", __func__, error);
        if (callback) {
            callback(error);
        }
    }];
    
}

- (void)submitConnectedAndMonitorBeacons:(NSArray *)logItems
                                callback:(nonnull void (^)(NSString * _Nullable, NSError * _Nullable))callback {
    NSMutableArray *items = [NSMutableArray arrayWithArray:logItems];
    
    NSArray *cachedItems = [[CacheHelper sharedInstance] getSubmitMonitorLog];
    if (cachedItems) {
        [items addObjectsFromArray:cachedItems];
    }
    
    NSString *jsonString = @"[]";
    if (items) {
        jsonString = [self convertNSArrayToJsonString:items];
    }
    
    NSDictionary *params = [self getBaseParams];
    NSString *path = [self addQueryStringToUrl:@"submitMonitor" params:params];
    [_sessionManager POST:path
               parameters:@{@"items": jsonString}
                 progress:nil
                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error;
        NSString *promotionMsg = nil;
        APIResponseModel *apiResponse = [[APIResponseModel alloc] initWithDictionary:responseObject error:&error];
        if (error) {
            NSLog(@"error: %@", error);
            [[CacheHelper sharedInstance] saveSubmitMonitorLog:items];
        } else {
            if (apiResponse.errorCode == 0) {
                error = nil;
                promotionMsg = apiResponse.data[@"mess_promotion"];
            } else {
                error = [NSError errorWithDomain:@"submitConnectedBeacons"
                                            code:apiResponse.errorCode
                                        userInfo:@{NSLocalizedDescriptionKey:apiResponse.errorMessage}];
            }
            [[CacheHelper sharedInstance] removeSubmitMonitorLog];
        }
        if (callback) {
            callback(promotionMsg, error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%s: %@", __func__, error);
        [[CacheHelper sharedInstance] saveSubmitMonitorLog:items];
        if (callback) {
            callback(nil, error);
        }
    }];
}

#pragma mark Private methods
- (NSString *)convertNSArrayToJsonString:(NSArray *)data {
    NSString *ret = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];
    if (error) {
        NSLog(@"%s: %@", __func__, error);
        ret = @"[]";
    } else {
        ret = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return ret;
}

- (NSArray *)convertDistanceDictionaryToArrayItems:(NSDictionary *) dict {
    NSMutableArray *ret = nil;
    
    do {
        if (dict == nil || dict.count == 0) {
            break;
        }
        ret = [NSMutableArray new];
        NSString *timestampString = [@([[NSDate date] timeIntervalSince1970]) stringValue];
        for (NSString *key in dict) {
            [ret addObject:@{
                @"id": key,
                @"distance": dict[key],
                @"ts": timestampString
            }];
        }
    } while (NO);
    
    return ret;
}

- (NSString *)convertZBeaconArrayToJsonString:(NSArray <ZBeacon*> *) beacons {
    NSString *ret = @"[]";
    
    do {
        if (beacons == nil || beacons.count == 0) {
            break;
        }
        NSMutableArray *items = [NSMutableArray new];
        NSString *timestampString = [@([[NSDate date] timeIntervalSince1970]) stringValue];
        for (ZBeacon *beacon in beacons) {
            NSUUID *uuid = beacon.UUID;
            if (uuid == nil) {
                continue;
            }
            
            [items addObject:@{
                @"id": uuid.UUIDString,
                @"distance": @([beacon distance]),
                @"ts": timestampString
            }];
        }
        ret = [self convertNSArrayToJsonString:items];
    } while (NO);
    
    return ret;
}

- (NSString *)getAppVersion {
    NSDictionary* infoDict = [[NSBundle bundleForClass:[self class]] infoDictionary];
    NSString* version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    return version;
}

- (NSString*)addQueryStringToUrl:(NSString *)urlString params:(NSDictionary *)params {
    NSURLComponents *components = [NSURLComponents componentsWithString:urlString];
    NSMutableArray *queryItems = [NSMutableArray array];
    for (NSString *key in params) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:params[key]]];
    }
    components.queryItems = queryItems;
    NSURL *url = components.URL;
    return url.absoluteString;
}

- (NSDictionary *)getBaseParams {
    UIDevice * device = [UIDevice currentDevice];
    NSDictionary *params = @{
        @"viewerkey": [ZaloSDK sharedInstance].zaloUserId,
        @"av": _appVersion,
        @"pl": PLATFORM,
        @"nw": [device connectionType],
        @"cell": [device mobileNetworkCode],
        @"cur_ts": [@([[NSDate date] timeIntervalSince1970]) stringValue]
    };
    return params;
}

@end
