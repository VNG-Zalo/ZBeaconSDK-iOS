//
//  ClearNavigationStackSegue.m
//  ZBeaconSDK_Example
//
//  Created by ToanTM on 26/11/2020.
//  Copyright © 2020 minhtoantm. All rights reserved.
//

#import "ClearNavigationStackSegue.h"

@implementation ClearNavigationStackSegue

- (void)perform {
    [self.sourceViewController.navigationController setViewControllers:@[self.destinationViewController] animated:YES];
    self.destinationViewController.navigationItem.hidesBackButton = YES;
}

@end
