//
//  UIDevice+Extension.h
//  ZBeaconSDK_Example
//
//  Created by ToanTM on 30/11/2020.
//  Copyright © 2020 VNG. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (Extension)

- (NSString *) connectionType;
- (NSString *) mobileNetworkCode;

@end

NS_ASSUME_NONNULL_END
