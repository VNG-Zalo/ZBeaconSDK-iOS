//
//  ZBeaconSDKTests.m
//  ZBeaconSDKTests
//
//  Created by minhtoantm on 11/20/2020.
//  Copyright (c) 2020 minhtoantm. All rights reserved.
//

@import XCTest;
#import "NetworkHelper.h"
#import <ZBeaconSDK/ZBeaconSDK.h>

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetMasterBeaconUUID {
    XCTestExpectation *promise = [[XCTestExpectation alloc] initWithDescription:@"beacon model list is not empty"];
    NetworkHelper *networkHelper = [NetworkHelper sharedInstance];
    __block NSArray *uuidList = nil;
    [networkHelper getMasterBeaconUUIDList:^(NSArray<NSString *> * _Nonnull uuids) {
        uuidList = uuids;
        [promise fulfill];
    }];
    [self waitForExpectations:@[promise] timeout:30];
    XCTAssertNotNil(uuidList);
    XCTAssertNotEqual(uuidList.count, 0);
}

- (void)testGetBeaconListForMasterBeaconUUID
{
    XCTestExpectation *promise = [[XCTestExpectation alloc] initWithDescription:@"beacon model list is not empty"];
    NetworkHelper *networkHelper = [NetworkHelper sharedInstance];
    __block NSArray *beaconModelList = nil;
    [networkHelper getBeaconListForMasterBeaconUUID:@"A382BCAE-69F2-4C42-8C46-48FFCF222269" callback:^(NSArray * _Nonnull beaconModels) {
        beaconModelList = beaconModels;
        [promise fulfill];
    }];
    [self waitForExpectations:@[promise] timeout:30];
    XCTAssertNotNil(beaconModelList);
    XCTAssertNotEqual(beaconModelList.count, 0);
}

- (void)testGetPromotionForBeaconUUID
{
    XCTestExpectation *promise = [[XCTestExpectation alloc] initWithDescription:@"beacon model list is not empty"];
    NetworkHelper *networkHelper = [NetworkHelper sharedInstance];
    __block BeaconPromotion *beaconPromotion = nil;
    [networkHelper getPromotionForBeaconUUID:@"A382BCAE-69F2-4C42-8C46-48FFCF222269" callback:^(BeaconPromotion * _Nonnull promotion) {
        beaconPromotion = promotion;
        [promise fulfill];
    }];
    
    [self waitForExpectations:@[promise] timeout:30];
    XCTAssertNotNil(beaconPromotion);
}

- (void)testSubmitConnectedBeacons {
    XCTestExpectation *promise = [[XCTestExpectation alloc] initWithDescription:@"error not nil"];
    NetworkHelper *networkHelper = [NetworkHelper sharedInstance];
    __block NSError *error = nil;
    
    ZBeacon *beacon = [[ZBeacon alloc] init];
    [networkHelper submitConnectedBeacons:@[beacon] callback:^(NSError * _Nullable e) {
        error = e;
        [promise fulfill];
    }];
    [self waitForExpectations:@[promise] timeout:30];
    XCTAssertNil(error);
}

- (void)testSubmitConnectedAndMonitorBeacons {
    XCTestExpectation *promise = [[XCTestExpectation alloc] initWithDescription:@"error not nil"];
    NetworkHelper *networkHelper = [NetworkHelper sharedInstance];
    __block NSError *error = nil;
    
    ZBeacon *beacon = [[ZBeacon alloc] init];
    [networkHelper submitConnectedAndMonitorBeacons:@[beacon] callback:^(NSError * _Nullable e) {
        error = e;
        [promise fulfill];
    }];
    [self waitForExpectations:@[promise] timeout:30];
    XCTAssertNil(error);
}

@end

