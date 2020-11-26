//
//  Logger.h
//  123ClickAdsSDK
//
//  Created by Liem Vo Uy on 9/19/13.
//  Copyright (c) 2013 VNG. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 SDK Log level
 */
typedef NS_ENUM(NSUInteger, ZBeaconLogLevel) {
    /**
     No log at all
     */
    ZBeaconLogNone = 0,
    /**
     Log all messages
     */
    ZBeaconLogVerbose = 1,
    /**
     Log debug, info, warn and error messages
     */
    ZBeaconLogDebug = 2,
    /**
     Log info, warn and error messages
     */
    ZBeaconLogInfo = 3,
    /**
     Log warn and error messages
     */
    ZBeaconLogWarn = 4,
    /**
     Only log error messages
     */
    ZBeaconLogError = 5,
};


@interface ZBeaconLogManager : NSObject
+ (void) setLogLevel: (ZBeaconLogLevel) logLevel;
+ (ZBeaconLogLevel) logLevel;
@end


extern void ZBeaconLog(NSString * format,...);
extern void ZBeaconLoge(NSString * format,...);
extern void ZBeaconLogw(NSString * format,...);
extern void ZBeaconLogi(NSString * format,...);
extern void ZBeaconLogd(NSString * format,...);
extern void ZBeaconLogv(NSString * format,...);

