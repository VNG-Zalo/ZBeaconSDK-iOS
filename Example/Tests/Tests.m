//
//  ZBeaconSDKTests.m
//  ZBeaconSDKTests
//
//  Created by minhtoantm on 11/20/2020.
//  Copyright (c) 2020 minhtoantm. All rights reserved.
//

@import XCTest;
#import "NetworkHelper.h"

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

- (void)testGetBeaconListForMasterBeaconUUID
{
    XCTestExpectation *promise = [[XCTestExpectation alloc] initWithDescription:@"beacon model list is not empty"];
    NetworkHelper *networkHelper = [NetworkHelper sharedInstance];
    __block NSArray *beaconModelList = nil;
    [networkHelper getBeaconListForMasterBeaconUUID:@"A382BCAE-69F2-4C42-8C46-48FFCF222269" callback:^(NSArray * _Nonnull beaconModels) {
        beaconModelList = beaconModels;
        [promise fulfill];
    }];
    XCTAssertNil(beaconModelList);
    XCTAssertEqual(beaconModelList.count, 0);
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
    XCTAssertNil(beaconPromotion);
}

@end

