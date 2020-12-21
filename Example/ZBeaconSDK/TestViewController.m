//
//  TestViewController.m
//  ZBeaconSDK_Example
//
//  Created by ToanTM on 16/12/2020.
//  Copyright © 2020 VNG. All rights reserved.
//

#import "TestViewController.h"
#import <ZBeaconSDK/ZBeaconSDK.h>

@interface TestViewController ()<ZBeaconSDKDelegate>

@property (strong, nonatomic) ZBeaconSDK *zBeaconSDK;
@property (weak, nonatomic) IBOutlet UIButton *btnStart;
@property (weak, nonatomic) IBOutlet UIButton *btnStop;
@property (weak, nonatomic) IBOutlet UITextField *txtNumberBeacons;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initZBeaconSDK];
    
    _btnStart.enabled = YES;
    _btnStop.enabled = NO;
}

- (void)initZBeaconSDK {
    _zBeaconSDK = [ZBeaconSDK sharedInstance];
    [_zBeaconSDK stopBeacons];
    _zBeaconSDK.delegate = self;
    _zBeaconSDK.enableExtendBackgroundRunningTime = YES;
    _zBeaconSDK.enableBeaconTimeout = NO;
    _zBeaconSDK.beaconTimeOutInterval = 10;
}

- (void)startTest {
    NSInteger endIndex = [self.txtNumberBeacons.text integerValue];
    
    _btnStart.enabled = NO;
    _btnStop.enabled = NO;
    
    [_zBeaconSDK stopBeacons];
    NSMutableArray *uuids = [NSMutableArray new];
    [uuids addObjectsFromArray:[self realUUIDs]];
    NSInteger startIndex = uuids.count;
    
    for (NSInteger i = startIndex; i < endIndex; i++) {
        [uuids addObject:[NSUUID UUID].UUIDString];
    }
    NSMutableArray *beaconDatas = [NSMutableArray new];
    for (NSString *uuidString in uuids) {
        ZRegion *beaconData = [[ZRegion alloc] initWithUUID:[[NSUUID alloc] initWithUUIDString:uuidString]];
        [beaconDatas addObject:beaconData];
    }
    [_zBeaconSDK setListBeacons:beaconDatas];
    NSLog(@"startTest: START init %lu beacon", (unsigned long)uuids.count);
    NSDate *startTime = [NSDate date];
    [_zBeaconSDK startBeaconsWithCompletion:^{
        NSDate *endTime = [NSDate date];
        NSLog(@"startTest: END init %lu beacon in %.3f", (unsigned long)uuids.count, [endTime timeIntervalSinceDate:startTime]);
        _btnStart.enabled = NO;
        _btnStop.enabled = YES;
    }];
}

- (NSArray*)realUUIDs {
    return @[
        @"399dade1-ef37-4a7f-90b3-3ce870b1457e",
        @"28f3ec0c-c0a3-4972-bbab-8c8068750e2c",
        @"e061420d-d3f8-492f-b484-91b71ee48b4a",
        @"8c377f7d-9956-4234-8e1e-685bbf158a7b",
        @"93383dbc-bd2c-44be-8b40-6d4ff589586d",
        @"6cbfbbfc-ec64-4c0e-8f7c-49dde93b60f9",
        @"43561749-4dfd-41e4-887d-15704807d4a9",
        @"bbc47a7d-7901-4d8c-b99c-af3f3c584a9c"
    ];
}

#pragma mark Button Action
- (IBAction)buttonStartPressed:(id)sender {
    [self startTest];
}

- (IBAction)buttonStopPressed:(id)sender {
    [_zBeaconSDK stopBeacons];
    _btnStart.enabled = YES;
    _btnStop.enabled = NO;
}


#pragma mark ZBeaconSDKDelegate
- (void)onBeaconConnected:(ZBeacon *)beacon {
    NSLog(@"%s: %@", __func__, [beacon debugDescription]);
}

- (void)onBeaconDisconnected:(ZBeacon *)beacon {
    NSLog(@"%s: %@", __func__, [beacon debugDescription]);
}

- (void)onRangeBeacons:(NSArray<ZBeacon *> *)beacons {
    if (!beacons || beacons.count == 0) {
        return;
    }
    
    for (NSInteger i = 0; i < beacons.count; i++) {
        ZBeacon *beacon = [beacons objectAtIndex:i];
        NSLog(@"%s: %ld %@ %@", __func__, (long)i, beacon.UUID.UUIDString,  [beacon locationString]);
    }
}

@end
