//
//  NSDate+Extension.m
//  ZBeaconSDK_Example
//
//  Created by ToanTM on 25/11/2020.
//  Copyright © 2020 minhtoantm. All rights reserved.
//

#import "NSDate+Extension.h"

@implementation NSDate (Extension)

-(NSDate *) toLocalTime {
  NSTimeZone *tz = [NSTimeZone defaultTimeZone];
  NSInteger seconds = [tz secondsFromGMTForDate: self];
  return [NSDate dateWithTimeInterval: seconds sinceDate: self];
}

@end
