//
//  NetworkHelper.m
//  ZBeaconSDK_Example
//
//  Created by ToanTM on 23/11/2020.
//  Copyright © 2020 minhtoantm. All rights reserved.
//

#import "NetworkHelper.h"
#import <AFNetworking/AFNetworking.h>
#import "APIResponse.h"
#import "BeaconModel.h"

#define APP_VERSION     @"123"
#define PLATFORM        @"1"

@interface NetworkHelper ()

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;

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
    }
    return self;
}

- (void)getMasterBeaconUUIDList:(void (^)(NSArray<NSString *> * _Nullable))callback {
    NSDictionary *params = @{
        @"viewerkey": @"1251521352rwfvrbksjpofdwjpge",
        @"av": APP_VERSION,
        @"pl": PLATFORM
    };
    [_sessionManager GET:@"getMasterBeacon"
              parameters:params
                progress:nil
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error;
        APIResponse *apiResponse = [[APIResponse alloc] initWithDictionary:responseObject error:&error];
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
        callback(uuids);
    }
                 failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"getMasterBeaconUUIDList error: %@", error);
        callback(nil);
    }];
}

- (void)getBeaconListForMasterBeaconUUID:(NSString *)uuidString callback:(void (^)(NSArray * _Nullable))callback {
    NSDictionary *params = @{
        @"viewerkey": @"1251521352rwfvrbksjpofdwjpge",
        @"av": APP_VERSION,
        @"pl": PLATFORM,
        @"bcid": uuidString
    };
    [_sessionManager GET:@"getAroundHere"
              parameters:params
                progress:nil
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error;
        APIResponse *apiResponse = [[APIResponse alloc] initWithDictionary:responseObject error:&error];
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
                beaconModels = [BeaconModel arrayOfModelsFromDictionaries:items];
            }
        }
        callback(beaconModels);
    }
                 failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@" getBeaconListForMasterBeaconUUID error: %@", error);
        callback(nil);
    }];
}

- (void)getPromotionForBeaconUUID:(NSString *)uuidString callback:(void (^)(BeaconPromotion * _Nullable))callback {
    NSDictionary *params = @{
        @"viewerkey": @"1251521352rwfvrbksjpofdwjpge",
        @"av": APP_VERSION,
        @"pl": PLATFORM,
        @"id": uuidString
    };
    [_sessionManager GET:@"promotion"
              parameters:params
                progress:nil
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error;
        APIResponse *apiResponse = [[APIResponse alloc] initWithDictionary:responseObject error:&error];
        BeaconPromotion *promotion = nil;
        if (error) {
            NSLog(@"error: %@", error);
        } else {
            if (apiResponse.errorCode != 0) {
                NSLog(@"getPromotionForBeaconUUID: errorCode=%ld errorMessage=%@", (long)apiResponse.errorCode, apiResponse.errorMessage);
            } else {
                NSError *error;
                promotion = [[BeaconPromotion alloc] initWithDictionary:apiResponse.data error:&error];
            }
        }
        callback(promotion);
    }
                 failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"getPromotionForBeaconUUID error: %@", error);
        callback(nil);
    }];
}

@end
