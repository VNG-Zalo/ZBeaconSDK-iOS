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
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "CacheHelper.h"
#import "ZBeacon+Extension.h"

#define TIME_WAITING_TO_COLLECT_ALL_CONNECTED_CLIENT_BEACONS 5

@interface ZViewController ()<ZBeaconSDKDelegate, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) ZBeaconSDK *zBeaconSDK;
@property (strong, nonatomic) NSArray<NSString*> *masterUUIDs;
@property (strong, nonatomic) ZBeacon *currentConnectedMasterBeacon;
@property (strong, nonatomic) ZBeacon *nearestBeacon;
@property (strong, nonatomic) NSMutableArray<ZBeacon*> *activeClientBeacons;
@property (strong, nonatomic) NSArray<BeaconModel*> *beaconModels;
@property (strong, nonatomic) NSTimer *collectClientBeaconsForTheFirstTimeConnectedTimer;
@property (strong, nonatomic) NSTimer *submitMonitorBeaconToServerTimer;
@property (strong, nonatomic) NSTimer *timeoutRestartMasterBeaconTimer;
@property (strong, nonatomic) NSTimer *timeoutClientBeaconTimer;
@property (assign, nonatomic) NSTimeInterval submitMonitorBeaconsToServerInterval;
@property (strong, nonatomic) NSMutableArray *monitorBeaconsTracker;
@property (assign, nonatomic) BOOL isSubmitingMonitorBeaconsToServer;
@property (strong, nonatomic) NSMutableDictionary *lastSubmitDistanceOfBeacons;
@property (assign, nonatomic) BOOL isSubmitMonitorBeaconsForTheFirstTime;
@property (strong, nonatomic) NSMutableDictionary *promotionDict;
@property (strong, nonatomic) NSString *userDisplayName;
@property (strong, nonatomic) NSString *emptyMessageForTableView;
@property (strong, nonatomic) NSString *currentMasterUUID;
@property (strong, nonatomic) NSString *currentMasterName;

@end

@implementation ZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"ZBeacon";
	
    _zBeaconSDK = [ZBeaconSDK sharedInstance];
    
    _zBeaconSDK.delegate = self;
    _zBeaconSDK.enableExtendBackgroundRunningTime = YES;
    _zBeaconSDK.enableBeaconTimeout = YES;
    _zBeaconSDK.beaconTimeOutInterval = 10;
    
    [self getClientBeaconFromAPI:nil];
    
    [self initNavigationBar];
    
    [self getUserDisplayNameWithCallback:nil];
    
    [self initTableView];

}

- (void)initTableView {
    _emptyMessageForTableView = @"";
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];
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
    NSLog(@"Start get master beacon uuid from API");
    [[NetworkHelper sharedInstance] getMasterBeaconUUIDList:^(NSArray<NSString *> * _Nullable uuids, NSError * _Nullable error) {
        
        if (uuids == nil || uuids.count == 0) {
            uuids = [[CacheHelper sharedInstance] getMasterUUIDs];
            NSLog(@"getMasterBeaconUUIDsFromAPI error, get from cache");
        } else {
            [[CacheHelper sharedInstance] saveMasterUUIDs:uuids];
        }
        if (uuids == nil || uuids.count == 0) {
            NSLog(@"ERROR: master beacon UUIDs empty with error %@", error);
        } else {
            [self handleMasterBeaconUUIDs: uuids];
        }
    }];
}

- (void)getClientBeaconFromAPI:(NSString *)uuidString {
   [[NetworkHelper sharedInstance] getBeaconListForMasterBeaconUUID:uuidString
                                          callback:^(NSArray<BeaconModel *> * _Nullable beaconModels, NSTimeInterval monitorInterval, NSTimeInterval expired, NSTimeInterval timeout, NSString * _Nullable nameOfMasterBeacon, NSError * _Nullable error) {
       _submitMonitorBeaconsToServerInterval = monitorInterval;
       _beaconModels = beaconModels;
       _currentMasterName = nameOfMasterBeacon;
       
       CacheHelper *cacheHelper = [CacheHelper sharedInstance];
       if (_beaconModels == nil || _beaconModels.count == 0) {
           _beaconModels = [cacheHelper getClientBeaconModelsOfMasterUUID:uuidString];
           _submitMonitorBeaconsToServerInterval = [cacheHelper getMonitorInterval];
           _currentMasterName = [cacheHelper getNameOfBeaconUUID:uuidString];
           NSLog(@"getBeaconListForMasterBeaconUUID error, get from cache");
       } else {
           [cacheHelper saveClientBeaconModels:_beaconModels ofMasterUUID:uuidString];
           [cacheHelper saveMonitorInterval:_submitMonitorBeaconsToServerInterval];
           [cacheHelper saveExpiredTimeOfClientBeacon:expired];
           [cacheHelper saveTimeOutOfClientBeacon:timeout];
           [cacheHelper saveName: _currentMasterName ofBeaconUUID:uuidString];
       }
       
       NSTimeInterval timeoutOfClient = [cacheHelper getTimeOutOfClientBeacon];
       if (timeoutOfClient > 0) {
           if (_timeoutClientBeaconTimer) {
               [_timeoutClientBeaconTimer invalidate];
           }
           _timeoutClientBeaconTimer = [NSTimer scheduledTimerWithTimeInterval:timeoutOfClient target:self selector:@selector(timeoutClientBeaconHanlde:) userInfo:nil repeats:NO];
       }
       
       if (_beaconModels == nil || _beaconModels.count == 0) {
           NSLog(@"ERROR: client for master %@ is empty. Error: %@\nEND FLOW--------", uuidString, error);
       } else {
           
           NSLog(@"Receive from API %ld client beacons of master %@", (long)_beaconModels.count, uuidString);
           NSMutableArray *beaconDatas = [NSMutableArray new];
           NSMutableString *emptyMessage = [NSMutableString new];
           [emptyMessage appendString:@"Listening CILENT UUIDs:"];
           for (BeaconModel *beaconModel in _beaconModels) {
               ZRegion *beaconData = [[ZRegion alloc] initWithUUID:[[NSUUID alloc] initWithUUIDString:beaconModel.identifier]];
               [beaconDatas addObject:beaconData];
               [emptyMessage appendFormat:@"\n%@", beaconModel.identifier];
           }
           // Add master to ranging
           if (uuidString && uuidString.length > 0) {
               ZRegion *beaconData = [[ZRegion alloc] initWithUUID:[[NSUUID alloc] initWithUUIDString:uuidString]];
               [beaconDatas addObject:beaconData];
           }
           
           _emptyMessageForTableView = emptyMessage;
           [_tableView reloadData];
           [_zBeaconSDK stopBeacons];
           NSLog(@"Stop master beacons\nStart init client beacons.");
           _isSubmitMonitorBeaconsForTheFirstTime = NO;
           [_zBeaconSDK setListBeacons:beaconDatas];
           [_zBeaconSDK startBeaconsWithCompletion:^(NSInteger errorCode, NSString * _Nullable errorMessage) {
               NSLog(@"Init %ld client beacons DONE with errorCode: %ld errorMessage: %@", (unsigned long)beaconDatas.count, (long)errorCode, errorMessage);
           }];
       }
   }];
}

- (void)handleMasterBeaconUUIDs:(NSArray *) uuids {
    _masterUUIDs = uuids;
    NSLog(@"Start init master beacon uuids: \n     %@", uuids);
    NSMutableArray *beaconDatas = [NSMutableArray new];
    for (NSString *uuidString in uuids) {
        ZRegion *beaconData = [[ZRegion alloc] initWithUUID:[[NSUUID alloc] initWithUUIDString:uuidString]];
        [beaconDatas addObject:beaconData];
    }
    [_zBeaconSDK setListBeacons:beaconDatas];
    
    _beaconModels = nil;
    _currentMasterUUID = nil;
    _currentMasterName = nil;
    
    NSMutableString *message = [NSMutableString new];
    [message appendString:@"Listening MASTER UUIDs:"];
    for (NSString *uuidString in _masterUUIDs) {
        [message appendFormat:@"\n%@", uuidString];
    }
    _emptyMessageForTableView = message;
    [_tableView reloadData];
    
    [_zBeaconSDK startBeaconsWithCompletion:^(NSInteger errorCode, NSString * _Nullable errorMessage) {
        NSLog(@"Init %ld client beacons DONE with errorCode: %ld errorMessage: %@", (unsigned long)beaconDatas.count, (long)errorCode, errorMessage);
    }];
}

- (void)handleConnectedMasterBeacon:(ZBeacon *)beacon {
    NSLog(@"%s: %@", __func__, [beacon debugDescription]);
    _currentConnectedMasterBeacon = beacon;
    _currentMasterUUID = beacon.UUID.UUIDString;
    
    // Get client beacon list
    NetworkHelper *networkHelper = [NetworkHelper sharedInstance];
    
    [self createNotificatonWithIdentifier:_currentMasterUUID title:[NSString stringWithFormat:@"Welcome to %@", _currentMasterName] message:nil];
    [self getClientBeaconFromAPI:_currentMasterUUID];
    
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
    NSArray *logItems = [NSArray arrayWithArray:_monitorBeaconsTracker];
    [_monitorBeaconsTracker removeAllObjects];
    [self saveLastSubmitDistanceOfBeacon:logItems];
    [[NetworkHelper sharedInstance] submitConnectedAndMonitorBeacons:logItems
                                                            callback:^(NSString * _Nullable promotionMessage, NSError * _Nullable error) {
        
        _isSubmitingMonitorBeaconsToServer = NO;
        if (error) {
            NSLog(@"%s: error %@", __func__, error);
        } else {
            
            [self getUserDisplayNameWithCallback:^(NSString * _Nullable displayName) {
                NSString *identifier = [@([[NSDate date] timeIntervalSince1970]) stringValue];
                NSString *title = [NSString stringWithFormat:@"Xin chào %@", _userDisplayName];
                [self createNotificatonWithIdentifier:identifier
                                                title:title
                                              message:promotionMessage];
            }];
        }
    }];
}

- (void)getUserDisplayNameWithCallback:(void(^)(NSString *_Nullable displayName)) callback {
    if (_userDisplayName && _userDisplayName.length > 0) {
        if (callback) {
            callback(_userDisplayName);
        }
    } else {
        [[ZaloSDK sharedInstance] getZaloUserProfileWithCallback:^(ZOGraphResponseObject *response) {
            NSString *name = nil;
            if (response.isSucess && response.data) {
                name = response.data[@"name"];
                _userDisplayName = name;
            }
            if (callback) {
                callback(name);
            }
        }];
    }
}


- (void)addBeaconToTracker:(ZBeacon*) beacon {
    // Check condition
    BeaconModel *beaconModel = [self findBeaconModelAdaptiveWithZBeacon:beacon];
    double lastSubmitDistance = [self lastSubmitDistanceOfBeacon:beacon];
    double beaconDistance = beacon.distance;
    double beaconModelDistance = beaconModel.distance;
    if (beaconModel == nil
        || beaconModel.monitor == nil
        || beaconModel.monitor.isEnable == NO
        || beaconDistance <= 0
        || beaconDistance > beaconModelDistance
        || (lastSubmitDistance > 0 && beaconDistance > 0 && fabs(beaconDistance - lastSubmitDistance) < beaconModel.monitor.movingRange)
        ) {
        if (beaconModel == nil) {
            NSLog(@"%s %@: return - beaconModel == nil", __func__, beacon.UUID.UUIDString);
        } else if (beaconModel.monitor == nil) {
            NSLog(@"%s %@: return - beaconModel.monitor == nil", __func__, beacon.UUID.UUIDString);
        } else if (beaconModel.monitor.isEnable == NO) {
            NSLog(@"%s %@: return - beaconModel.monitor.isEnable == NO", __func__, beacon.UUID.UUIDString);
        } else if (beaconDistance <= 0) {
            NSLog(@"%s %@: return - beaconDistance <= 0", __func__, beacon.UUID.UUIDString);
        } else if (beaconDistance > beaconModelDistance) {
            NSLog(@"%s %@: return - beacon.distance(%.3f) > beaconModel.distance(%.3f)", __func__, beacon.UUID.UUIDString, beaconDistance, beaconModelDistance);
        } else if ((lastSubmitDistance > 0 && beaconDistance > 0 && fabs(beaconDistance - lastSubmitDistance) < beaconModel.monitor.movingRange)) {
            NSLog(@"%s %@: return - beacon.distance(%.3f) - lastSubmitDistance(%.3f) < beaconModel.monitor.movingRange(%.3f)", __func__, beacon.UUID.UUIDString, beaconDistance, lastSubmitDistance, beaconModel.monitor.movingRange);
        }
        return;
    }
    
    if (!_monitorBeaconsTracker) {
        _monitorBeaconsTracker = [NSMutableArray new];
    }
    NSString *timestampString = [@([[NSDate date] timeIntervalSince1970]) stringValue];
    [_monitorBeaconsTracker addObject:@{@"id": beacon.UUID.UUIDString,
                                        @"distance": @([beacon distance]),
                                        @"ts": timestampString}];
    
    NSLog(@"%s %@: SUCCESS - beacon.distance(%.3f) beaconModel.distance(%.3f) lastSubmitDistance(%.3f) beaconModel.monitor.movingRange(%.3f)", __func__, beacon.UUID.UUIDString, beaconDistance, beaconModelDistance, lastSubmitDistance, beaconModel.monitor.movingRange);
}

- (void)saveLastSubmitDistanceOfBeacon:(NSArray*) logItems {
    if (logItems == nil || logItems.count == 0) {
        return;
    }
    if (_lastSubmitDistanceOfBeacons == nil) {
        _lastSubmitDistanceOfBeacons = [NSMutableDictionary new];
    }
    for (NSDictionary *dict in logItems) {
        NSString *key = dict[@"id"];
        NSNumber *distance = dict[@"distance"];
        
        if (key == nil || key.length == 0 || distance == nil) {
            continue;
        }
        if (_lastSubmitDistanceOfBeacons[key] != nil) {
            continue;
        }
        _lastSubmitDistanceOfBeacons[key] = distance;
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
            NSLog(@"Get promotion for beacon %@ error: %@", uuidString, error);
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
    NSLog(@"Disconnected to master beacon → Stop all client beacon and timeout for restart master beacon. Master beacon:%@", [beacon debugDescription]);
    if (!_timeoutRestartMasterBeaconTimer) {
        _timeoutRestartMasterBeaconTimer = [NSTimer scheduledTimerWithTimeInterval:[[CacheHelper sharedInstance] getTimeOutOfClientBeacon]
                                                                            target:self
                                                                          selector:@selector(restartMasterBeacon:)
                                                                          userInfo:nil
                                                                           repeats:NO];
    }
}

- (void)timeoutClientBeaconHanlde:(id) sender {
    if (_timeoutClientBeaconTimer) {
        [_timeoutClientBeaconTimer invalidate];
        _timeoutClientBeaconTimer = nil;
    }
    [self getClientBeaconFromAPI:(_nearestBeacon ? _nearestBeacon.UUID.UUIDString : nil)];
}

- (void)restartMasterBeacon:(id) sender {
    if (_timeoutRestartMasterBeaconTimer) {
        [_timeoutRestartMasterBeaconTimer invalidate];
        _timeoutRestartMasterBeaconTimer = nil;
    }
    NSLog(@"%s", __func__);
    [_zBeaconSDK stopBeacons];
    _currentMasterUUID = nil;
    _currentMasterName = nil;
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
    
    return;
    
    if (_activeClientBeacons.count > 0) {
        NSLog(@"Disconnected to client beacon. But still %ld active client beacons → Do nothing .Client beacon:%@", (long)_activeClientBeacons.count, [beacon debugDescription]);
        return;
    }
    
    if (_currentConnectedMasterBeacon != nil) {
        NSLog(@"Disconnected to client beacon. But master beacon still connected → Do nothing .Client beacon:%@", [beacon debugDescription]);
        return;
    }
    
    // Out of all client beacons, restart master beacon
    NSLog(@"Disconnected to client beacon. All of client beacon is disconnected → Stop all client beacon and timeout for restart master beacons. Master beacon:%@", [beacon debugDescription]);
    if (!_timeoutRestartMasterBeaconTimer) {
        _timeoutRestartMasterBeaconTimer = [NSTimer scheduledTimerWithTimeInterval:[[CacheHelper sharedInstance] getTimeOutOfClientBeacon]
                                                                            target:self
                                                                          selector:@selector(restartMasterBeacon:)
                                                                          userInfo:nil
                                                                           repeats:NO];
    }
}

#pragma mark ZBeaconSDKDelegate

- (void)onBeaconConnected:(ZBeacon *)beacon {
    NSLog(@"%s: %@", __func__, [beacon debugDescription]);
    
    // Check beacon is in master uuids
    if ([_masterUUIDs containsObject:beacon.UUID.UUIDString]) {
        NSLog(@"Connected to master beacon: %@ major=%@ minor=%@", beacon.UUID.UUIDString, beacon.major, beacon.minor);
        [self handleConnectedMasterBeacon: beacon];
    } else {
        NSLog(@"Connected to client beacon: %@ major=%@ minor=%@", beacon.UUID.UUIDString, beacon.major, beacon.minor);
        [self handleConnectedClientBeacon: beacon];
    }
}

- (void)onBeaconDisconnected:(ZBeacon *)beacon {
    NSLog(@"%s: %@", __func__, [beacon debugDescription]);
    
    // Check beacon is in master uuids
    if ([_masterUUIDs containsObject:beacon.UUID.UUIDString]) {
        NSLog(@"Disconnected to master beacon: %@ major=%@ minor=%@", beacon.UUID.UUIDString, beacon.major, beacon.minor);
        [self handleDisconnectedMasterBeacon: beacon];
    } else {
        NSLog(@"Disconnected to client beacon: %@ major=%@ minor=%@", beacon.UUID.UUIDString, beacon.major, beacon.minor);
        [self handleDisconnectedClientBeacon: beacon];
    }
    [_tableView reloadData];
}

- (void)onRangeBeacons:(NSArray<ZBeacon *> *)beacons {
    for (ZBeacon *beacon in beacons) {
        [self addBeaconToTracker: beacon];
        if (!_nearestBeacon || beacon.distance < _nearestBeacon.distance) {
            _nearestBeacon = beacon;
        }
    }
    
    [_tableView reloadData];
}

- (void)onErrorWithErrorCode:(NSInteger)errorCode errorMessage:(NSString *)errorMessage {
    NSLog(@"%s %ld %@", __func__, (unsigned long)errorCode, errorMessage);
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return (_currentConnectedMasterBeacon || (_currentMasterUUID && _currentMasterUUID.length > 0)) ? 1 : 0;
    } else {
        return _activeClientBeacons.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Item" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        ZBeacon *beacon = _currentConnectedMasterBeacon;
        cell.beacon = beacon;
        cell.currentBeaconUUID = _currentMasterUUID;
        cell.beaconName = _currentMasterName;
        cell.beaconPromotion = nil;
        [cell refreshInformation];
    } else {
        ZBeacon *beacon = [_activeClientBeacons objectAtIndex:indexPath.row];
        cell.beacon = beacon;
        cell.currentBeaconUUID = beacon.UUID.UUIDString;
        PromotionModel *promotionModel = [_promotionDict objectForKey:beacon.UUID.UUIDString];
        if (promotionModel) {
            cell.beaconName = promotionModel.banner;
            cell.beaconPromotion = promotionModel.theDescription;
        } else {
            cell.beaconName = nil;
            cell.beaconPromotion = nil;
        }
        [cell refreshInformation];
    }
    return  cell;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if (_currentConnectedMasterBeacon == nil && (!_currentMasterUUID || _currentMasterUUID.length == 0) && _activeClientBeacons.count == 0) {
//        return nil;
//    }
//    if (section == 0) {
//        return @"Master beacons";
//    }
//    return @"Client beacons";
//}

#pragma mark DZNEmptyDataSetSource
- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
                                 
    return [[NSAttributedString alloc] initWithString:_emptyMessageForTableView attributes:attributes];
}
#pragma mark DZNEmptyDataSetDelegate
- (BOOL)emptyDataSetShouldBeForcedToDisplay:(UIScrollView *)scrollView {
    BOOL ret = NO;
    
    do {
        if (_activeClientBeacons == nil && _activeClientBeacons.count == 0) {
            ret = YES;
            break;
        }
        
        if (_activeClientBeacons && _activeClientBeacons.count == 0) {
            ret = YES;
            break;
        }
        
    } while (NO);
    
    return ret;
}

@end
