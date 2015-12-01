//
//  LoginViewController.m
//  RCSDKDemo
//
//  Created by HyoungEun Kim on 2015. 9. 24..
//  Copyright © 2015-present Rankwave Co.,Ltd. All rights reserved.
//

#import "LoginViewController.h"
#import "Common.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <RCSDKCoreKit/RCSDKCoreKit.h>

#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>

#import <KakaoOpenSDK/KakaoOpenSDK.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Hide top navigation bar.
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loginToFacebook:(id)sender {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    
    /////////////////////////////////////////
    // Permission list must be set.
    [login logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if(error) {
            NSLog(@"Facebook Login failed. %@", [error localizedDescription]);
        }
        else if(result.isCancelled) {
            NSLog(@"Facebook Login cancelled. %@", [error localizedDescription]);
        }
        else {
            if([FBSDKAccessToken currentAccessToken]) {
                NSString *userID = [[FBSDKAccessToken currentAccessToken] userID];
                NSString *token = [[FBSDKAccessToken currentAccessToken] tokenString];
                
                NSLog(@"Facebook Login succeeded. User ID = %@", userID);
                
                ///////////////////////////////////////////////////
                // FOR RC SDK
                ///////////////////////////////////////////////////
                
                [[RCSDK sharedInstance] loginWithFacebookID:userID withToken:token response:^(NSString *response, NSError *error) {
                    if(response) {
                        NSLog(@"RANK.CLOUD login with Facebook ID succeeded. %@", response);
                    }
                    
                    if(error) {
                        NSLog(@"RANK.CLOUD login with Facebook ID failed. %@", [error localizedDescription]);
                    }
                }];
                
                ///////////////////////////////////////////////////
                
                // Save current session.
                [Common saveSessionID:userID withSNS:@"facebook" withToken:token withTokenSecret:nil];
                
                // Switch to service view controller.
                [Common switchView:VIEW_TYPE_SERVICE];
            }
        }
    }];
}

- (IBAction)loginToTwitter:(id)sender {
    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
        if(session) {
            NSString *userID = session.userID;
            NSString *token = session.authToken;
            NSString *tokenSecret = session.authTokenSecret;
            
            NSLog(@"Twitter Login succeeded. User ID = %@", userID);
            
            ///////////////////////////////////////////////////
            // FOR RC SDK
            ///////////////////////////////////////////////////
            
            [[RCSDK sharedInstance] loginWithTwitterID:userID withToken:token
                                       withTokenSecret:tokenSecret response:^(NSString *response, NSError *error) {
                if(response) {
                    NSLog(@"RANK.CLOUD login with Twitter ID succeeded. %@", response);
                }
                
                if(error) {
                    NSLog(@"RANK.CLOUD login with Twitter ID failed. %@", [error localizedDescription]);
                }
            }];
            
            // Save current session.
            [Common saveSessionID:userID withSNS:@"twitter" withToken:token withTokenSecret:tokenSecret];
            
            // Switch to service view controller.
            [Common switchView:VIEW_TYPE_SERVICE];
        }
        else {
            NSLog(@"Twitter Login failed. %@", [error localizedDescription]);
        }
    }];
}

- (IBAction)loginToKakao:(id)sender {
    // ensure old session was closed
    [[KOSession sharedSession] close];
    
    [[KOSession sharedSession] openWithCompletionHandler:^(NSError *error) {
        if ([[KOSession sharedSession] isOpen]) {
            [KOSessionTask meTaskWithCompletionHandler:^(KOUser* result, NSError *error) {
                if(result) {
                    // success
                    NSString *token = [KOSession sharedSession].accessToken;
                    NSString *refreshToken = [KOSession sharedSession].refreshToken;
                    
                    NSString *userID = [result.ID stringValue];
                    NSLog(@"Kakao Login succeeded. User ID = %@", result.ID);
                    
                    ///////////////////////////////////////////////////
                    // FOR RC SDK
                    ///////////////////////////////////////////////////
                    
                    [[RCSDK sharedInstance] loginWithKakaoID:userID withToken:token withRefreshToken:refreshToken
                            response:^(NSString *response, NSError *error) {
                                   if(response) {
                                       NSLog(@"RANK.CLOUD login with Kakao ID succeeded. %@", response);
                                   }
                                   
                                   if(error) {
                                       NSLog(@"RANK.CLOUD login with Kakao ID failed. %@", [error localizedDescription]);
                                   }
                               }];
                    
                    // Save current session.
                    [Common saveSessionID:result.ID.stringValue withSNS:@"kakao" withToken:token withTokenSecret:nil];
                    
                    // Switch to service view controller.
                    [Common switchView:VIEW_TYPE_SERVICE];
                }
                else {
                    NSLog(@"Kakao Login failed. %@", [error localizedDescription]);
                }
            }];
        } else {
            NSLog(@"Kakao Login failed. %@", [error localizedDescription]);
        }
    }];
}
@end
