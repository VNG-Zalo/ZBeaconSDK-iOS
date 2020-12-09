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
#import <OCMock/OCMock.h>

@interface NetworkTest : XCTestCase

@end

@implementation NetworkTest

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
    [networkHelper getMasterBeaconUUIDList:^(NSArray<NSString *> * _Nullable uuids, NSError * _Nullable error) {
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
    [networkHelper getBeaconListForMasterBeaconUUID:@"A382BCAE-69F2-4C42-8C46-48FFCF222269" callback:^(NSArray<BeaconModel *> * _Nullable beaconModels, NSTimeInterval monitorInterval, NSTimeInterval expired, NSError * _Nullable error) {
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
    __block PromotionModel *beaconPromotion = nil;
    [networkHelper getPromotionForBeaconUUID:@"A382BCAE-69F2-4C42-8C46-48FFCF222269" callback:^(PromotionModel * _Nullable promotionModel, NSError * _Nullable error) {
        beaconPromotion = promotionModel;
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
    id objectMock = OCMPartialMock(beacon);
    OCMStub([objectMock distance])._andReturn(@15);
    OCMStub([objectMock UUID]).andReturn([NSUUID UUID]);

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
    id objectMock = OCMPartialMock(beacon);
    OCMStub([objectMock distance])._andReturn(@15);
    OCMStub([objectMock UUID]).andReturn([[NSUUID alloc] initWithUUIDString:@"F06B3BB9-D8CD-4F8C-A6D8-97F8DCDE5D4E"]);
    NSDictionary *distances = @{
        beacon.UUID.UUIDString: @(beacon.distance)
    };
    
    [networkHelper submitConnectedAndMonitorBeacons:distances callback:^(NSString * _Nullable promotionMessage, NSError * _Nullable e) {
        error = e;
        [promise fulfill];
    }];
    [self waitForExpectations:@[promise] timeout:30];
    XCTAssertNil(error);
}

@end

