//
//  UIDevice+Extension.m
//  ZBeaconSDK_Example
//
//  Created by ToanTM on 30/11/2020.
//  Copyright © 2020 VNG. All rights reserved.
//

#import "UIDevice+Extension.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreTelephony/CTCarrier.h>

@implementation UIDevice (Extension)

- (NSString *)connectionType {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, "8.8.8.8");
    SCNetworkReachabilityFlags flags;
    BOOL success = SCNetworkReachabilityGetFlags(reachability, &flags);
    CFRelease(reachability);
    if (!success) {
        return @"unknown";
    }
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL isNetworkReachable = (isReachable && !needsConnection);
    
    if (!isNetworkReachable) {
        return @"none";
    } else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        return @"3g";
    } else {
        return @"wifi";
    }
}

- (NSString *)mobileNetworkCode {
#if TARGET_IPHONE_SIMULATOR
    return @"45.201";
#endif
    
    static NSString * mnc = nil;
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = networkInfo.subscriberCellularProvider;
    if (carrier.mobileCountryCode.length > 0 && carrier.mobileNetworkCode.length > 0) {
        mnc = [NSString stringWithFormat:@"%@.%@", carrier.mobileCountryCode, carrier.mobileNetworkCode];
    }
    if (mnc == nil) {
        mnc = @"";
    }
    return mnc;
}

@end
