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
#import "ItemCell.h"
#import <ZaloSDK/ZaloSDK.h>

#define TIME_WAITING_TO_COLLECT_ALL_CONNECTED_CLIENT_BEACONS 5

@interface ZViewController ()<ZBeaconSDKDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) ZBeaconSDK *zBeaconSDK;
@property (strong, nonatomic) NSArray<NSString*> *masterUUIDs;
@property (strong, nonatomic) ZBeacon *currentConnectedMasterBeacon;
@property (strong, nonatomic) NSMutableArray<ZBeacon*> *activeClientBeacons;
@property (strong, nonatomic) NSArray<BeaconModel*> *beaconModels;
@property (strong, nonatomic) NSTimer *collectClientBeaconsForTheFirstTimeConnectedTimer;
@property (strong, nonatomic) NSTimer *submitMonitorBeaconToServerTimer;
@property (assign, nonatomic) NSTimeInterval submitMonitorBeaconsToServerInterval;
@property (strong, nonatomic) NSMutableDictionary *monitorBeaconsTracker;
@property (assign, nonatomic) BOOL isSubmitingMonitorBeaconsToServer;
@property (strong, nonatomic) NSMutableDictionary *lastSubmitDistanceOfBeacons;
@property (assign, nonatomic) BOOL isSubmitMonitorBeaconsForTheFirstTime;
@property (strong, nonatomic) NSMutableDictionary *promotionDict;

@end

@implementation ZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"ZBeacon";
	
    _zBeaconSDK = [ZBeaconSDK sharedInstance];
    [_zBeaconSDK stopBeacons];
    _zBeaconSDK.delegate = self;
    _zBeaconSDK.enableExtendBackgroundRunningTime = YES;
    
    [self getMasterBeaconUUIDsFromAPI];
    
    [self initNavigationBar];

}

- (void)initNavigationBar {
    UIBarButtonItem *logoutBtn = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonPressed:)];
    self.navigationItem.rightBarButtonItem = logoutBtn;
}

- (void)logoutButtonPressed:(id)sender {
    [[ZaloSDK sharedInstance] unauthenticate];
    [self performSegueWithIdentifier:@"showLoginController" sender:self];
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
}

- (void)createNotificationWithZBeacon:(ZBeacon *)beacon promotionModel:(PromotionModel*)promotionModel {
    [self createNotificatonWithIdentifier:beacon.UUID.UUIDString
                                    title:promotionModel.banner
                                  message:promotionModel.theDescription];
}

- (void)createNotificatonWithIdentifier:(NSString*)identifier
                                  title:(NSString*)title
                                message:(NSString*)message {
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = title;
    content.body = message;
    content.sound = UNNotificationSound.defaultSound;
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:nil];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Add notification for %@ fail", identifier);
        } else {
            NSLog(@"Add notification for %@ success", identifier);
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
    _currentConnectedMasterBeacon = beacon;
    
    // Get client beacon list
    NetworkHelper *networkHelper = [NetworkHelper sharedInstance];
    [networkHelper getBeaconListForMasterBeaconUUID:_currentConnectedMasterBeacon.UUID.UUIDString
                                           callback:^(NSArray<BeaconModel *> * _Nullable beaconModels, NSTimeInterval monitorInterval, NSTimeInterval expired, NSError * _Nullable error) {
        _submitMonitorBeaconsToServerInterval = monitorInterval;
        _beaconModels = beaconModels;
        if (_beaconModels == nil || _beaconModels.count == 0) {
            [self addLog: [NSString stringWithFormat:@"ERROR: client for master %@ is empty. Error: %@\nEND FLOW--------", _currentConnectedMasterBeacon.UUID.UUIDString, error]];
        } else {
            
            [self addLog:[NSString stringWithFormat:@"Receive from API %ld client beacons of master %@", (long)_beaconModels.count, _currentConnectedMasterBeacon.UUID.UUIDString]];
            NSMutableArray *clientUUIDs = [NSMutableArray new];
            for (BeaconModel *beaconModel in _beaconModels) {
                [clientUUIDs addObject:beaconModel.identifier];
            }
            // Add master to ranging
            [clientUUIDs addObject:_currentConnectedMasterBeacon.UUID.UUIDString];
            
            [_zBeaconSDK stopBeacons];
            [self addLog:@"Stop master beacons\nStart init client beacons."];
            _isSubmitMonitorBeaconsForTheFirstTime = NO;
            [_zBeaconSDK setListBeacons:clientUUIDs];
            [_zBeaconSDK startBeaconsWithCompletion:^{
                [self addLog:@"Init client beacons DONE"];
            }];
        }
    }];
    
    [networkHelper submitConnectedBeacons:@[_currentConnectedMasterBeacon]
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
    
    BeaconModel *beaconModel = [self findBeaconModelAdaptiveWithZBeacon:beacon];
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
    [self addBeaconToTracker: beacon];
    
    if (!_isSubmitMonitorBeaconsForTheFirstTime) {
        if (_activeClientBeacons.count == _beaconModels.count) {
            [self submitClientBeaconsForTheFirstTime:nil];
        } else if (_collectClientBeaconsForTheFirstTimeConnectedTimer == nil) {
            _collectClientBeaconsForTheFirstTimeConnectedTimer = [NSTimer scheduledTimerWithTimeInterval:TIME_WAITING_TO_COLLECT_ALL_CONNECTED_CLIENT_BEACONS
                                                                                                  target:self
                                                                                                selector:@selector(submitClientBeaconsForTheFirstTime:)
                                                                                                userInfo:nil
                                                                                                 repeats:NO];
        }
    }
}

- (BeaconModel*)findBeaconModelAdaptiveWithZBeacon:(ZBeacon*)beacon {
    NSString *uuidString = beacon.UUID.UUIDString;
    NSArray *filteredArray = [_beaconModels filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(BeaconModel *beaconModel, NSDictionary *bindings) {
        return [beaconModel.identifier isEqual:uuidString];
    }]];
    BeaconModel *beaconModel = filteredArray.firstObject;
    return beaconModel;
}

- (void)submitClientBeaconsForTheFirstTime:(id) sender {
    if (_collectClientBeaconsForTheFirstTimeConnectedTimer) {
        [_collectClientBeaconsForTheFirstTimeConnectedTimer invalidate];
        _collectClientBeaconsForTheFirstTimeConnectedTimer = nil;
    }
    [self submitMonitorBeaconsToServer:nil];
    [self startTimerIntervalToSubmitMonitorBeacons];
    _isSubmitMonitorBeaconsForTheFirstTime = YES;
}

- (void)startTimerIntervalToSubmitMonitorBeacons {
    if (_submitMonitorBeaconToServerTimer) {
        [_submitMonitorBeaconToServerTimer invalidate];
    }
    
    _submitMonitorBeaconToServerTimer = [NSTimer scheduledTimerWithTimeInterval:_submitMonitorBeaconsToServerInterval
                                                                                 target:self
                                                                               selector:@selector(submitMonitorBeaconsToServer:)
                                                                               userInfo:nil
                                                                                repeats:YES];
}

- (void)submitMonitorBeaconsToServer:(id) sender {
    
    if (_monitorBeaconsTracker == nil || _monitorBeaconsTracker.count == 0) {
        NSLog(@"%s: tracker empty", __func__);
        return;
    }
    if (_isSubmitingMonitorBeaconsToServer) {
        NSLog(@"%s: submiting", __func__);
        return;
    }
    
    _isSubmitingMonitorBeaconsToServer = YES;
    NSMutableDictionary *jsonDict = [NSMutableDictionary new];
    for (NSString *key in _monitorBeaconsTracker) {
        NSArray *distance = _monitorBeaconsTracker[key];
        NSNumber *average = [distance valueForKeyPath:@"@avg.self"];
        jsonDict[key] = average;
    }
    NSDictionary *backup = [NSDictionary dictionaryWithDictionary:_monitorBeaconsTracker];
    [_monitorBeaconsTracker removeAllObjects];
    [[NetworkHelper sharedInstance] submitConnectedAndMonitorBeacons:jsonDict
                                                            callback:^(NSString * _Nullable promotionMessage, NSError * _Nullable error) {
        
        _isSubmitingMonitorBeaconsToServer = NO;
        if (error) {
            NSLog(@"%s: error %@", __func__, error);
            // Restore backup
            for (NSString *key in backup) {
                NSMutableArray *distances = _monitorBeaconsTracker[key];
                if (distances == nil) {
                    distances = backup[key];
                } else {
                    [distances addObjectsFromArray:backup[key]];
                }
                _monitorBeaconsTracker[key] = distances;
            }
        } else {
            [self saveLastSubmitDistanceOfBeacon:jsonDict];
            [[ZaloSDK sharedInstance] getZaloUserProfileWithCallback:^(ZOGraphResponseObject *response) {
                if (response && response.isSucess) {
                    NSString *identifier = [@([[NSDate date] timeIntervalSince1970]) stringValue];
                    NSString *title = response.data[@"name"];
                    [self createNotificatonWithIdentifier:identifier
                                                    title:title
                                                  message:promotionMessage];
                }
            }];
        }
    }];
}


- (void)addBeaconToTracker:(ZBeacon*) beacon {
    // Check condition
    BeaconModel *beaconModel = [self findBeaconModelAdaptiveWithZBeacon:beacon];
    double lastSubmitDistance = [self lastSubmitDistanceOfBeacon:beacon];
    if (beaconModel == nil
        || beaconModel.monitor == nil
        || beaconModel.monitor.isEnable == NO
        || beacon.distance > beaconModel.distance
        || (lastSubmitDistance > 0 && (beacon.distance - lastSubmitDistance) < beaconModel.monitor.movingRange)
        ) {
        if (beaconModel == nil) {
            NSLog(@"%s %@: return - beaconModel == nil", __func__, beacon.UUID.UUIDString);
        } else if (beaconModel.monitor == nil) {
            NSLog(@"%s %@: return - beaconModel.monitor == nil", __func__, beacon.UUID.UUIDString);
        } else if (beaconModel.monitor.isEnable == NO) {
            NSLog(@"%s %@: return - beaconModel.monitor.isEnable == NO", __func__, beacon.UUID.UUIDString);
        } else if (beacon.distance > beaconModel.distance) {
            NSLog(@"%s %@: return - beacon.distance(%.3f) > beaconModel.distance(%.3f)", __func__, beacon.UUID.UUIDString, beacon.distance, beaconModel.distance);
        } else if ((lastSubmitDistance > 0 && (beacon.distance - lastSubmitDistance) < beaconModel.monitor.movingRange)) {
            NSLog(@"%s %@: return - beacon.distance(%.3f) - lastSubmitDistance(%.3f) < beaconModel.monitor.movingRange(%.3f)", __func__, beacon.UUID.UUIDString, beacon.distance, lastSubmitDistance, beaconModel.monitor.movingRange);
        }
        return;
    }
    
    if (!_monitorBeaconsTracker) {
        _monitorBeaconsTracker = [NSMutableDictionary new];
    }
    NSString *key = beacon.UUID.UUIDString;
    NSMutableArray *distances = [_monitorBeaconsTracker objectForKey:key];
    if (!distances) {
        distances = [NSMutableArray new];
    }
    [distances addObject:@(beacon.distance)];
    _monitorBeaconsTracker[key] = distances;
}

- (void)saveLastSubmitDistanceOfBeacon:(NSDictionary*) beacons {
    if (beacons == nil || beacons.count == 0) {
        return;
    }
    if (_lastSubmitDistanceOfBeacons == nil) {
        _lastSubmitDistanceOfBeacons = [NSMutableDictionary new];
    }
    for (NSString *key in beacons) {
        NSNumber *distance = beacons[key];
        if (distance) {
            _lastSubmitDistanceOfBeacons[key] = distance;
        }
    }
}

- (double)lastSubmitDistanceOfBeacon:(ZBeacon*)beacon {
    double ret = 0;
    
    do {
        if (_lastSubmitDistanceOfBeacons == nil) {
            break;
        }
        NSNumber *distance = _lastSubmitDistanceOfBeacons[beacon.UUID.UUIDString];
        if (distance == nil) {
            break;
        }
        ret = [distance doubleValue];
    } while (NO);
    
    return ret;
}

- (void)showPromotionForBeacon:(ZBeacon *) beacon {
    NSString *uuidString = beacon.UUID.UUIDString;
    [[NetworkHelper sharedInstance] getPromotionForBeaconUUID:uuidString
                                    callback:^(PromotionModel * _Nullable promotionModel, NSError * _Nullable error) {
        if (promotionModel) {
            if (_promotionDict == nil) {
                _promotionDict = [NSMutableDictionary new];
            }
            _promotionDict[beacon.UUID.UUIDString] = promotionModel;
            [_tableView reloadData];
            [self createNotificationWithZBeacon:beacon promotionModel:promotionModel];
        } else {
            [self addLog:[NSString stringWithFormat:@"Get promotion for beacon %@ error: %@", uuidString, error]];
        }
    }];
}

- (void)handleDisconnectedMasterBeacon:(ZBeacon *)beacon {
    
    if (_currentConnectedMasterBeacon != beacon) {
        NSLog(@"%s: currentMasterBeacon %@ is different, do nothing with %@", __func__, [_currentConnectedMasterBeacon debugDescription], [beacon debugDescription]);
        return;
    }
    
    _currentConnectedMasterBeacon = nil;
    if (_activeClientBeacons.count > 0) {
        NSLog(@"Disconnected to master beacon, but active client beacons still contain %ld → Do nothing. Master beacon:%@", (long)_activeClientBeacons.count, [beacon debugDescription]);
        return;
    }
    NSLog(@"Disconnected to master beacon → Stop all client beacon and restart master beacon. Master beacon:%@", [beacon debugDescription]);
    [_zBeaconSDK stopBeacons];
    if (_masterUUIDs != nil && _masterUUIDs.count > 0) {
        [self handleMasterBeaconUUIDs:_masterUUIDs];
    } else {
        [self getMasterBeaconUUIDsFromAPI];
    }
}

- (void)handleDisconnectedClientBeacon:(ZBeacon *)beacon {
    
    if (_activeClientBeacons) {
        [_activeClientBeacons removeObject:beacon];
    }
    
    if (_activeClientBeacons.count > 0) {
        NSLog(@"Disconnected to client beacon. But still %ld active client beacons → Do nothing .Client beacon:%@", (long)_activeClientBeacons.count, [beacon debugDescription]);
        return;
    }
    
    if (_currentConnectedMasterBeacon != nil) {
        NSLog(@"Disconnected to client beacon. But master beacon still connected → Do nothing .Client beacon:%@", [beacon debugDescription]);
        return;
    }
    
    // Out of all client beacons, restart master beacon
    NSLog(@"Disconnected to client beacon. All of client beacon is disconnected → Stop all client beacon and restart master beacons. Master beacon:%@", [beacon debugDescription]);
    
    [_zBeaconSDK stopBeacons];
    if (_masterUUIDs != nil && _masterUUIDs.count > 0) {
        [self handleMasterBeaconUUIDs:_masterUUIDs];
    } else {
        [self getMasterBeaconUUIDsFromAPI];
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
    [_tableView reloadData];
}

- (void)onRangeBeacons:(NSArray<ZBeacon *> *)beacons {
    for (ZBeacon *beacon in beacons) {
        [self addBeaconToTracker: beacon];
    }
    [_tableView reloadData];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return _activeClientBeacons.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Item" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        ZBeacon *beacon = _currentConnectedMasterBeacon;
        cell.beacon = beacon;
        [cell refreshInformation];
    } else {
        ZBeacon *beacon = [_activeClientBeacons objectAtIndex:indexPath.row];
        cell.beacon = beacon;
        cell.promotionModel = [_promotionDict objectForKey:beacon.UUID.UUIDString];
        [cell refreshInformation];
    }
    return  cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Master beacons";
    } else {
        return @"Client beacons";
    }
}


@end
