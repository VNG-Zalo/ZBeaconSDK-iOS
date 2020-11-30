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
@property (strong, nonatomic) NSArray<NSString*> *masterUUIDs;
@property (strong, nonatomic) ZBeacon *currentMasterBeacon;
@property (strong, nonatomic) NSMutableArray<ZBeacon*> *activeClientBeacons;
@property (strong, nonatomic) NSArray<BeaconModel*> *beaconModels;

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
    
    // Get client beacon list
    NetworkHelper *networkHelper = [NetworkHelper sharedInstance];
    [networkHelper getBeaconListForMasterBeaconUUID:_currentMasterBeacon.UUID.UUIDString
                                                            callback:^(NSArray * _Nullable beaconModels, NSError * _Nullable error) {
        _beaconModels = beaconModels;
        if (_beaconModels == nil || _beaconModels.count == 0) {
            [self addLog: [NSString stringWithFormat:@"ERROR: client for master %@ is empty. Error: %@\nEND FLOW--------", _currentMasterBeacon.UUID.UUIDString, error]];
        } else {
            
            [self addLog:[NSString stringWithFormat:@"Receive from API %ld client beacons of master %@", (long)_beaconModels.count, _currentMasterBeacon.UUID.UUIDString]];
            NSMutableArray *clientUUIDs = [NSMutableArray new];
            for (BeaconModel *beaconModel in _beaconModels) {
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
    
    [networkHelper submitConnectedBeacons:@[_currentMasterBeacon]
                                 callback:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"%s: error %@", __func__, error);
        } else {
            NSLog(@"%s: success", __func__);
        }
    }];
}

- (void)handleConnectedClientBeacon:(ZBeacon *)beacon {
    NSLog(@"%s: %@", __func__, [beacon debugDescription]);
    if (_activeClientBeacons == nil) {
        _activeClientBeacons = [NSMutableArray new];
    }
    [_activeClientBeacons addObject:beacon];
    
    [self showPromotionForBeacon:beacon];
    
    [self handleLogForClientBeacon:beacon];
}

- (void) handleLogForClientBeacon:(ZBeacon *) beacon {
    NSString *uuidString = beacon.UUID.UUIDString;
    NSArray *filteredArray = [_beaconModels filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(BeaconModel *beaconModel, NSDictionary *bindings) {
        return [beaconModel.identifier isEqual:uuidString];
    }]];
    BeaconModel *beaconModel = filteredArray.firstObject;
    if (beaconModel == nil) {
        return;
    }
    
    if (beaconModel.monitor.isEnable == NO) {
        // monitor.enable = NO, submit only
        [[NetworkHelper sharedInstance] submitConnectedBeacons:@[beacon]
                                                      callback:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"%s: error %@", __func__, error);
            } else {
                NSLog(@"%s: success", __func__);
            }
        }];
        return;
    }
    
    // monitor.enable = YES, add to log
}

- (void)showPromotionForBeacon:(ZBeacon *) beacon {
    NSString *uuidString = beacon.UUID.UUIDString;
    [[NetworkHelper sharedInstance] getPromotionForBeaconUUID:uuidString
                                    callback:^(PromotionModel * _Nullable promotionModel, NSError * _Nullable error) {
        if (promotionModel) {
            [self createNotificationWithZBeacon:beacon promotionModel:promotionModel];
        } else {
            [self addLog:[NSString stringWithFormat:@"Get promotion for beacon %@ error: %@", uuidString, error]];
        }
    }];
}

- (void)handleDisconnectedMasterBeacon:(ZBeacon *)beacon {
    if (_currentMasterBeacon == nil) {
        // Receive disconnected from all client beacon first
        return;
    }
    if (_currentMasterBeacon != beacon) {
        NSLog(@"%s: currentMasterBeacon %@ is different, do nothing with %@", __func__, [_currentMasterBeacon debugDescription], [beacon debugDescription]);
        return;
    }
    NSLog(@"Disconnected to master beacon → Stop all client beacon and restart master beacon. Master beacon:%@", [beacon debugDescription]);
    _currentMasterBeacon = nil;
    if (_activeClientBeacons) {
        [_activeClientBeacons removeAllObjects];
    }
    [_zBeaconSDK stopBeacons];
    if (_masterUUIDs != nil && _masterUUIDs.count > 0) {
        [self handleMasterBeaconUUIDs:_masterUUIDs];
    } else {
        [self getMasterBeaconUUIDsFromAPI];
    }
}

- (void)handleDisconnectedClientBeacon:(ZBeacon *)beacon {
    if (_activeClientBeacons.count == 0) {
        // Receive disconnected from master beacon first.
        return;
    }
    if (_activeClientBeacons) {
        [_activeClientBeacons removeObject:beacon];
    }
    // Out of all client beacons, restart master beacon
    if (_activeClientBeacons.count == 0) {
        NSLog(@"Disconnected to client beacon. All of client beacon is disconnected → Stop all client beacon and restart master beacons. Master beacon:%@", [beacon debugDescription]);
        _currentMasterBeacon = nil;
        [_zBeaconSDK stopBeacons];
        if (_masterUUIDs != nil && _masterUUIDs.count > 0) {
            [self handleMasterBeaconUUIDs:_masterUUIDs];
        } else {
            [self getMasterBeaconUUIDsFromAPI];
        }
    } else {
        NSLog(@"Disconnected to client beacon. But still %ld active client beacons → Do nothing .Client beacon:%@", (long)_activeClientBeacons.count, [beacon debugDescription]);
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
