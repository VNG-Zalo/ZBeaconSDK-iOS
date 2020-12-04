//
//  MiscTest.m
//  ZBeaconSDK_Tests
//
//  Created by ToanTM on 01/12/2020.
//  Copyright © 2020 VNG. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface MiscTest : XCTestCase

@end

@implementation MiscTest

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

- (void)testAverageOfNSArray {
    NSArray *numbers = @[@(2.4), @(2.6), @(4.0), @(4.0)];
    NSNumber *average = [numbers valueForKeyPath:@"@avg.self"];
    XCTAssertEqual([average doubleValue], 3.25);
}

- (void)testABS {
    double test = fabs(1-25.2345);
    XCTAssertEqual(test, 24.2345);
}

@end
