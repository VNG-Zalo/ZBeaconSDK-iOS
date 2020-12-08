//
//  CacheTest.m
//  ZBeaconSDK_Tests
//
//  Created by ToanTM on 07/12/2020.
//  Copyright © 2020 VNG. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CacheHelper.h"

@interface CacheTest : XCTestCase

@end

@implementation CacheTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testCacheMasterUUID {
    NSArray *masterUUID = @[
        @"D3720B9D-8B53-4B6D-975B-CB65D82161B0",
        @"A382BCAE-69F2-4C42-8C46-48FFCF222269",
        @"95552F3E-E0BB-4778-80CF-9B4DB93D4665",
        @"2CDDEA13-7BAF-4030-A477-29447634EA0D"
    ];
    CacheHelper *cacheHelper = [CacheHelper sharedInstance];
    [cacheHelper saveMasterUUIDs:masterUUID];
    NSArray *cachedMasterUUID = [cacheHelper getMasterUUIDs];
    XCTAssertEqualObjects(masterUUID, cachedMasterUUID);
}

- (void)testCacheClientBeacon {
    NSString *masterUUID = @"D3720B9D-8B53-4B6D-975B-CB65D82161B0";
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"BeaconModels" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSError *error;
    NSArray* beaconModels = [BeaconModel arrayOfModelsFromDictionaries:jsonDict error:&error];
    CacheHelper *cacheHelper = [CacheHelper sharedInstance];
    [cacheHelper saveClientBeaconModels:beaconModels ofMasterUUID:masterUUID];
    NSArray *cachedClientBeaconModels = [cacheHelper getClientBeaconModelsOfMasterUUID:masterUUID];
    XCTAssertEqual(beaconModels.count, cachedClientBeaconModels.count);
}

@end
