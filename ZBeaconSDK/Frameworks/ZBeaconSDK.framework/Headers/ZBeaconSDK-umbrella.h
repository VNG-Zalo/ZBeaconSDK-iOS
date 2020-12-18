#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "ZBeaconSDK.h"
#import "ZBeaconLogManager.h"
#import "ZBeaconSDKDelegate.h"
#import "ZRegion.h"
#import "ZBeacon.h"

FOUNDATION_EXPORT double ZBeaconSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char ZBeaconSDKVersionString[];

