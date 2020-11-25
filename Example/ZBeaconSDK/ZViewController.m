//
//  ZViewController.m
//  ZBeaconSDK
//
//  Created by minhtoantm on 11/20/2020.
//  Copyright (c) 2020 minhtoantm. All rights reserved.
//

#import "ZViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <ZBeaconSDK/ZBeaconSDK.h>
#import "NetworkHelper.h"
#import "NSDate+Extension.h"
#import "BeaconModel.h"

@interface ZViewController ()<ZBeaconSDKDelegate>

@property (weak, nonatomic) IBOutlet UITextView *txtLogging;

@property (strong, nonatomic) ZBeaconSDK *zBeaconSDK;
@property (strong, nonatomic) NSArray *masterUUIDs;
@property (strong, nonatomic) ZBeacon *currentMasterBeacon;
@property (strong, nonatomic) NSMutableArray *activeClientBeacons;

@end

@implementation ZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _zBeaconSDK = [ZBeaconSDK sharedInstance];
    [_zBeaconSDK stopBeacons];
    _zBeaconSDK.delegate = self;
    
    [self getMasterBeaconUUIDsFromAPI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)buttonStartAPIPressed:(id)sender {
    
    [[NetworkHelper sharedInstance] submitConnectedBeacons:@[] callback:^(NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
    
    
}

#pragma mark Private Utils Methods
- (void)addLog:(NSString *)log {
    NSLog(@"%@", log);
    NSString *currentLog = self.txtLogging.text;
    NSString *appendLog = [NSString stringWithFormat:@"%@: %@", [[NSDate date] toLocalTime], log];
    self.txtLogging.text = [NSString stringWithFormat:@"%@\n%@", currentLog, appendLog];
}

- (void)createNotificationWithZBeacon:(ZBeacon *)beacon promotionModel:(PromotionModel*)promotionModel {
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = promotionModel.banner;
    content.body = promotionModel.theDescription;
    content.sound = UNNotificationSound.defaultSound;
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:beacon.UUID.UUIDString content:content trigger:nil];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Add notification for %@ fail", beacon.UUID.UUIDString);
        } else {
            NSLog(@"Add notification for %@ success", beacon.UUID.UUIDString);
        }
    }];
}

#pragma mark Flow Methods
- (void)getMasterBeaconUUIDsFromAPI {
    [self addLog:@"Start get master beacon uuid from API"];
    [[NetworkHelper sharedInstance] getMasterBeaconUUIDList:^(NSArray<NSString *> * _Nullable uuids, NSError * _Nullable error) {
        if (uuids == nil || uuids.count == 0) {
            [self addLog: [NSString stringWithFormat:@"ERROR: master beacon UUIDs empty with error %@", error]];
        } else {
            [self handleMasterBeaconUUIDs: uuids];
        }
    }];
}

- (void)handleMasterBeaconUUIDs:(NSArray *) uuids {
    _masterUUIDs = uuids;
    [self addLog:[NSString stringWithFormat:@"Start init master beacon uuids: \n     %@", uuids]];
    [_zBeaconSDK setListBeacons:uuids];
    [_zBeaconSDK startBeaconsWithCompletion:^{
        [self addLog:@"Init master beacon uuids DONE"];
    }];
}

- (void)handleConnectedMasterBeacon:(ZBeacon *)beacon {
    NSLog(@"%s: %@", __func__, [beacon debugDescription]);
    _currentMasterBeacon = beacon;
    [[NetworkHelper sharedInstance] getBeaconListForMasterBeaconUUID:beacon.UUID.UUIDString
                                                            callback:^(NSArray * _Nullable beaconModels, NSError * _Nullable error) {
        if (beaconModels == nil || beaconModels.count == 0) {
            [self addLog: [NSString stringWithFormat:@"ERROR: client for master %@ is empty. Error: %@\nEND FLOW--------", beacon.UUID.UUIDString, error]];
        } else {
            [self addLog:[NSString stringWithFormat:@"Receive from API %ld client beacons of master %@", (long)beaconModels.count, beacon.UUID.UUIDString]];
            NSMutableArray *clientUUIDs = [NSMutableArray new];
            for (BeaconModel *beaconModel in beaconModels) {
                [clientUUIDs addObject:beaconModel.identifier];
            }
            // Add master to ranging
            [clientUUIDs addObject:_currentMasterBeacon.UUID.UUIDString];
            
            [_zBeaconSDK stopBeacons];
            [self addLog:@"Stop master beacons\nStart init client beacons."];
            [_zBeaconSDK setListBeacons:clientUUIDs];
            [_zBeaconSDK startBeaconsWithCompletion:^{
                [self addLog:@"Init client beacons DONE"];
            }];
        }
    }];
}

- (void)handleConnectedClientBeacon:(ZBeacon *)beacon {
    NSLog(@"%s: %@", __func__, [beacon debugDescription]);
    if (_activeClientBeacons == nil) {
        _activeClientBeacons = [NSMutableArray new];
    }
    [_activeClientBeacons addObject:beacon];
    [[NetworkHelper sharedInstance] getPromotionForBeaconUUID:beacon.UUID.UUIDString
                                                     callback:^(PromotionModel * _Nullable promotionModel, NSError * _Nullable error) {
        if (promotionModel) {
            [self createNotificationWithZBeacon:beacon promotionModel:promotionModel];
        } else {
            [self addLog:[NSString stringWithFormat:@"Get promotion for beacon %@ error: %@", beacon.UUID.UUIDString, error]];
        }
    }];
}

- (void)handleDisconnectedMasterBeacon:(ZBeacon *)beacon {
    if (_currentMasterBeacon != beacon) {
        NSLog(@"%s: currentMasterBeacon %@ is different, do nothing with %@", __func__, [_currentMasterBeacon debugDescription], [beacon debugDescription]);
        return;
    }
    NSLog(@"%s: %@", __func__, [beacon debugDescription]);
    [_zBeaconSDK stopBeacons];
    if (_masterUUIDs != nil && _masterUUIDs.count > 0) {
        [self handleMasterBeaconUUIDs:_masterUUIDs];
    } else {
        [self getMasterBeaconUUIDsFromAPI];
    }
}

- (void)handleDisconnectedClientBeacon:(ZBeacon *)beacon {
    NSLog(@"%s: %@", __func__, [beacon debugDescription]);
    if (_activeClientBeacons) {
        [_activeClientBeacons removeObject:beacon];
    }
    // Out of all client beacons, restart master beacon
    if (_activeClientBeacons.count == 0) {
        [_zBeaconSDK stopBeacons];
        if (_masterUUIDs != nil && _masterUUIDs.count > 0) {
            [self handleMasterBeaconUUIDs:_masterUUIDs];
        } else {
            [self getMasterBeaconUUIDsFromAPI];
        }
    }
}

#pragma mark ZBeaconSDKDelegate

- (void)onBeaconConnected:(ZBeacon *)beacon {
    NSLog(@"%s: %@", __func__, [beacon debugDescription]);
    
    // Check beacon is in master uuids
    if ([_masterUUIDs containsObject:beacon.UUID.UUIDString]) {
        [self addLog:[NSString stringWithFormat:@"Connected to master beacon: %@ major=%@ minor=%@", beacon.UUID.UUIDString, beacon.major, beacon.minor]];
        [self handleConnectedMasterBeacon: beacon];
    } else {
        [self addLog:[NSString stringWithFormat:@"Connected to client beacon: %@ major=%@ minor=%@", beacon.UUID.UUIDString, beacon.major, beacon.minor]];
        [self handleConnectedClientBeacon: beacon];
    }
}

- (void)onBeaconDisconnected:(ZBeacon *)beacon {
    NSLog(@"%s: %@", __func__, [beacon debugDescription]);
    
    // Check beacon is in master uuids
    if ([_masterUUIDs containsObject:beacon.UUID.UUIDString]) {
        [self addLog:[NSString stringWithFormat:@"Disconnected to master beacon: %@ major=%@ minor=%@", beacon.UUID.UUIDString, beacon.major, beacon.minor]];
        [self handleDisconnectedMasterBeacon: beacon];
    } else {
        [self addLog:[NSString stringWithFormat:@"Disconnected to client beacon: %@ major=%@ minor=%@", beacon.UUID.UUIDString, beacon.major, beacon.minor]];
        [self handleDisconnectedClientBeacon: beacon];
    }
}

- (void)onRangeBeacons:(NSArray<ZBeacon *> *)beacons {
//    NSLog(@"%s: %@", __func__, [beacons debugDescription]);
}

@end
