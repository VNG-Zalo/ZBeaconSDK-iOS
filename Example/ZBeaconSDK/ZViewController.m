//
//  ZViewController.m
//  ZBeaconSDK
//
//  Created by minhtoantm on 11/20/2020.
//  Copyright (c) 2020 minhtoantm. All rights reserved.
//

#import "ZViewController.h"
#import <ZBeaconSDK/ZBeaconSDK.h>

@interface ZViewController ()

@end

@implementation ZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [ZBeaconSDK sharedInstance];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
