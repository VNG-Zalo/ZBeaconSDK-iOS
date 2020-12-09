//
//  ZBeacon+Extension.m
//  ZBeaconSDK_Example
//
//  Created by ToanTM on 08/12/2020.
//  Copyright © 2020 VNG. All rights reserved.
//

#import "ZBeacon+Extension.h"

@implementation ZBeacon (Extension)

- (NSString *)asKey {
    NSMutableString *ret = [NSMutableString new];
    
    NSUUID *uuid = self.UUID;
    if (uuid) {
        [ret appendString:uuid.UUIDString];
    }
    
    NSNumber *major = self.major;
    if (major) {
        [ret appendFormat:@"_%@", major];
    }
    
    NSNumber *minor = self.minor;
    if (minor) {
        [ret appendFormat:@"_%@", minor];
    }
    
    return ret;
}

@end
