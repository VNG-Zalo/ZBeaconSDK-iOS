//
//  LoginViewController.m
//  ZBeaconSDK_Example
//
//  Created by ToanTM on 26/11/2020.
//  Copyright © 2020 VNG. All rights reserved.
//

#import "LoginViewController.h"
#import <ZaloSDK/ZaloSDK.h>
#import <AFNetworkReachabilityManager.h>

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@end

@implementation LoginViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self checkIsAuthenticated];
}

- (IBAction)buttonLoginPressed:(id)sender {
    [self login];
}

- (void)login {
    [[ZaloSDK sharedInstance] authenticateZaloWithAuthenType:ZAZAloSDKAuthenTypeViaZaloAppAndWebView parentController:self isShowLoading:YES handler:^(ZOOauthResponseObject *response) {
        [self onAuthenticateCompleteWithResponse:response];
    }];
}

- (void)onAuthenticateCompleteWithResponse:(ZOOauthResponseObject *) response {
    [_loadingIndicator stopAnimating];
    _btnLogin.hidden = NO;
    
    if (!response) {
        return;
    }
    
    if (response.isSucess) {
        [self showMainController];
    } else if (response.errorCode != -1001) { // Not cancel
        [self showAlertWithTitle:[NSString stringWithFormat:@"Error: %ld", (long)response.errorCode] message:response.errorMessage];
    }
}

- (void)showMainController {
    [self performSegueWithIdentifier:@"showMainController" sender:self];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString*) message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)checkIsAuthenticated {
    _btnLogin.hidden = YES;
    
    if ([[AFNetworkReachabilityManager manager] isReachable]) {
        [_loadingIndicator startAnimating];
        [[ZaloSDK sharedInstance] isAuthenticatedZaloWithCompletionHandler:^(ZOOauthCheckingResponseObject *response) {
            [self.loadingIndicator stopAnimating];
            if (response.isSucess) {
                [self showMainController];
            } else {
                self.btnLogin.hidden = NO;
            }
        }];
    } else {
        BOOL isAuthenticated = [[ZaloSDK sharedInstance] isAuthenticatedZaloWithCompletionHandler:nil];
        if (isAuthenticated) {
            [self showMainController];
        } else {
            self.btnLogin.hidden = NO;
        }
    };
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
