//
//  NetworkHelper.m
//  ZBeaconSDK_Example
//
//  Created by ToanTM on 23/11/2020.
//  Copyright © 2020 minhtoantm. All rights reserved.
//

#import "NetworkHelper.h"
#import <AFNetworking/AFNetworking.h>
#import <ZBeaconSDK/ZBeaconSDK.h>
#import "APIResponseModel.h"
#import "BeaconModel.h"

#define PLATFORM        @"2" // 1: android; 2: ios
#define VIEWER_KEY      @"866775211783397205.1606211643448.017ae60a7162487afa61514ec63adf66"

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

- (NSString *)getAppVersion {
    NSDictionary* infoDict = [[NSBundle bundleForClass:[self class]] infoDictionary];
    NSString* version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    return version;
}

- (void)getMasterBeaconUUIDList:(void (^)(NSArray<NSString *> * _Nullable, NSError * _Nullable))callback {
    NSDictionary *params = @{
        @"viewerkey": VIEWER_KEY,
        @"av": _appVersion,
        @"pl": PLATFORM
    };
    [_sessionManager GET:@"getMasterBeacon"
              parameters:params
                progress:nil
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error;
        APIResponseModel *apiResponse = [[APIResponseModel alloc] initWithDictionary:responseObject error:&error];
        NSArray *uuids = nil;
        if (error) {
            NSLog(@"error: %@", error);
        } else {
            if (apiResponse.errorCode != 0) {
                NSLog(@"getMasterBeaconUUIDList: errorCode=%ld errorMessage=%@", (long)apiResponse.errorCode, apiResponse.errorMessage);
            } else {
                uuids = [((NSDictionary *)apiResponse.data) objectForKey:@"items"];
            }
        }
        callback(uuids, error);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"getMasterBeaconUUIDList error: %@", error);
        callback(nil, error);
    }];
}

- (void)getBeaconListForMasterBeaconUUID:(NSString *)uuidString
                                callback:(void (^)(NSArray * _Nullable, NSError * _Nullable))callback {
    NSDictionary *params = @{
        @"viewerkey": VIEWER_KEY,
        @"av": _appVersion,
        @"pl": PLATFORM,
        @"bcid": uuidString
    };
    [_sessionManager GET:@"getAroundHere"
              parameters:params
                progress:nil
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error;
        APIResponseModel *apiResponse = [[APIResponseModel alloc] initWithDictionary:responseObject error:&error];
        NSMutableArray *beaconModels = nil;
        if (error) {
            NSLog(@"error: %@", error);
        } else {
            if (apiResponse.errorCode != 0) {
                NSLog(@"getBeaconListForMasterBeaconUUID: errorCode=%ld errorMessage=%@", (long)apiResponse.errorCode, apiResponse.errorMessage);
            } else {
                NSInteger monitorInterval = [apiResponse.data[@"monitor_interval"] intValue];
                NSInteger expired = [apiResponse.data[@"expire"] intValue];
                NSLog(@"getBeaconListForMasterBeaconUUID: monitorInterval=%ld expired=%ld", (long)monitorInterval, (long)expired);
                NSArray *items = apiResponse.data[@"items"];
                beaconModels = [BeaconModel arrayOfModelsFromDictionaries:items error:&error];
                if (error) {
                    NSLog(@"getBeaconListForMasterBeaconUUID error: %@", error);
                }
            }
        }
        callback(beaconModels, error);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"getBeaconListForMasterBeaconUUID error: %@", error);
        callback(nil, error);
    }];
}

- (void)getPromotionForBeaconUUID:(NSString *)uuidString
                         callback:(void (^)(PromotionModel * _Nullable, NSError * _Nullable))callback {
    NSDictionary *params = @{
        @"viewerkey": VIEWER_KEY,
        @"av": _appVersion,
        @"pl": PLATFORM,
        @"id": uuidString
    };
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
            } else {
                NSError *error;
                promotion = [[PromotionModel alloc] initWithDictionary:apiResponse.data error:&error];
                if (error) {
                    NSLog(@"getPromotionForBeaconUUID error: %@", error);
                }
            }
        }
        callback(promotion, error);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"getPromotionForBeaconUUID error: %@", error);
        callback(nil, error);
    }];
}

- (void)submitConnectedBeacons:(NSArray *)beacons callback:(void (^)(NSError * _Nullable))callback {
    
    NSString *jsonString = [self convertZBeaconArrayToJsonString:beacons];
    
    NSDictionary *params = @{
        @"viewerkey": VIEWER_KEY,
        @"av": _appVersion,
        @"pl": PLATFORM,
        @"items": jsonString
    };
    
    [_sessionManager POST:@"submit"
               parameters:params
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
        callback(error);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%s: %@", __func__, error);
        callback(error);
    }];
    
}

- (void)submitConnectedAndMonitorBeacons:(NSArray *)beacons callback:(void (^)(NSError * _Nullable))callback {
    NSString *jsonString = [self convertZBeaconArrayToJsonString:beacons];
    
    NSDictionary *params = @{
        @"viewerkey": VIEWER_KEY,
        @"av": _appVersion,
        @"pl": PLATFORM,
        @"items": jsonString
    };
    
    [_sessionManager POST:@"submitMonitor"
               parameters:params
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
        callback(error);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%s: %@", __func__, error);
        callback(error);
    }];
}

- (NSString *)convertZBeaconArrayToJsonString:(NSArray <ZBeacon*> *) beacons {
    NSString *ret = @"[]";
    
    do {
        if (beacons == nil || beacons.count == 0) {
            break;
        }
        NSMutableArray *items = [NSMutableArray new];
        for (ZBeacon *beacon in beacons) {
            if (beacon.UUID == nil) {
                continue;
            }
            [items addObject:@{
                @"id": beacon.UUID.UUIDString,
                @"distance": @(beacon.distance)
            }];
        }
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:items options:0 error:&error];
        if (error) {
            NSLog(@"%s: %@", __func__, error);
            break;
        }
        ret = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } while (NO);
    
    return ret;
}

@end
