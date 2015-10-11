//
//  ServiceViewController.m
//  RCSDKDemo
//
//  Created by HyoungEun Kim on 2015. 9. 24..
//  Copyright © 2015-present Rankwave Co.,Ltd. All rights reserved.
//

#import "ServiceViewController.h"
#import "Common.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <RCSDKCoreKit/RCSDKCoreKit.h>

#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>

@interface ServiceViewController ()

@end

@implementation ServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *sns = [Common getSNSFromSession];

    if([sns isEqualToString:@"facebook"]) {
        NSString *loginID = [Common getLoginIDFromSession];
        NSString *token = [Common getTokenFromSession];

        NSString *appendText = @"";

        appendText = [appendText stringByAppendingString:@"\n---------------------------"];
        appendText = [appendText stringByAppendingString:@"\n[Current logged-in session]"];
        appendText = [appendText stringByAppendingString:@"\n---------------------------"];
        appendText = [appendText stringByAppendingFormat:@"\nSNS = %@", sns];
        appendText = [appendText stringByAppendingFormat:@"\nID = %@", loginID];
        appendText = [appendText stringByAppendingFormat:@"\nToken = %@", token];
        appendText = [appendText stringByAppendingString:@"\n---------------------------\n"];
        
        _logText.text = [_logText.text stringByAppendingString:appendText];
        [_logText scrollRangeToVisible:NSMakeRange([_logText.text length], 0)];        
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:@"id,name,link" forKey:@"fields"];
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:param]
            startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if(!error) {
                    // Setting user's name
                    NSString *name = [result objectForKey:@"name"];
                    _name.text = name;
                }
            }
        ];
        
        // Setting user's profile image.
        NSString *profileURL = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture?type=large", loginID];
        
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileURL]]
                queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                               
                    [(NSHTTPURLResponse *)response allHeaderFields];
           
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
           
                    if(httpResponse.statusCode == 200) {
                        _profileImage.image = [UIImage imageWithData:data];
           }
        }];
    }
    else if([sns isEqualToString:@"twitter"]) {
        NSString *loginID = [Common getLoginIDFromSession];
        NSString *token = [Common getTokenFromSession];
        NSString *tokenSecret = [Common GetTokenSecretFromSession];
        
        NSString *appendText = @"";
        
        appendText = [appendText stringByAppendingString:@"\n---------------------------"];
        appendText = [appendText stringByAppendingString:@"\n[Current logged-in session]"];
        appendText = [appendText stringByAppendingString:@"\n---------------------------"];
        appendText = [appendText stringByAppendingFormat:@"\nSNS = %@", sns];
        appendText = [appendText stringByAppendingFormat:@"\nID = %@", loginID];
        appendText = [appendText stringByAppendingFormat:@"\nToken = %@", token];
        appendText = [appendText stringByAppendingFormat:@"\nToken Secret = %@", tokenSecret];
        appendText = [appendText stringByAppendingString:@"\n---------------------------\n"];
        
        _logText.text = [_logText.text stringByAppendingString:appendText];
        [_logText scrollRangeToVisible:NSMakeRange([_logText.text length], 0)];
 
        TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:loginID];
        NSString *userShowEndpoint = @"https://api.twitter.com/1.1/users/show.json";
        NSDictionary *params = @{@"user_id" : loginID};
        NSError *clientError;
        
        NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:userShowEndpoint parameters:params error:&clientError];
        
        if(request) {
            [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if(data) {
                    // handle the response data e.g.
                    NSError *jsonError;
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                    
                    // Setting user's name.
                    NSString *name = [json objectForKey:@"name"];
                    _name.text = name;
                    
                    // Setting user's profile image.
                    NSString *profileURL = [json objectForKey:@"profile_image_url"];
                    
                    // Converting profile url for small size to original size. https://xxxxx_normal.jpg -> https://xxxxx.jpg
                    profileURL = [profileURL stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
                    
                    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileURL]]
                                        queue:[NSOperationQueue mainQueue]
                                        completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                            [(NSHTTPURLResponse *)response allHeaderFields];
                                           
                                            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                           
                                            if(httpResponse.statusCode == 200) {
                                                _profileImage.image = [UIImage imageWithData:data];
                                            }
                                        }
                     ];
                }
                else {
                    NSLog(@"Twitter API Error: %@", connectionError);
                }
            }];
        }
        else {
            NSLog(@"Twitter API Error: %@", clientError);
        }
    }
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

- (IBAction)logout:(id)sender {
    // Logout from SNS
    NSString *sns = [Common getSNSFromSession];
    
    if([sns isEqualToString:@"facebook"]) {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        
        [login logOut];
    }
    else if([sns isEqualToString:@"twitter"]) {

        TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
        NSString *userID = store.session.userID;
        
        [store logOutUserID:userID];
    }
    
    ///////////////////////////////////////////////////
    // FOR RC SDK
    ///////////////////////////////////////////////////
    
    [[RCSDK sharedInstance] logout:^(NSString *response, NSError *error) {
            if(response) {
                NSLog(@"Calling RANK.CLOUD 'logout' module succeeded. %@", response);
            }
            
            if(error) {
                NSLog(@"Calling RANK.CLOUD 'logout' module failed. %@", [error localizedDescription]);
            }
        }
    ];

    ///////////////////////////////////////////////////
    
    NSString *appendText = @"";
    appendText = [appendText stringByAppendingString:@"\n---------------------------"];
    appendText = [appendText stringByAppendingString:@"\nCalled RANK.CLOUD 'logout' module."];
    appendText = [appendText stringByAppendingString:@"\n---------------------------\n"];
    
    _logText.text = [_logText.text stringByAppendingString:appendText];
    [_logText scrollRangeToVisible:NSMakeRange([_logText.text length], 0)];
    
    // Clear session value.
    [Common clearSession];
    [Common switchView:VIEW_TYPE_LOGIN];
}

- (IBAction)leave:(id)sender {
    // Logout from SNS
    NSString *sns = [Common getSNSFromSession];
    
    if([sns isEqualToString:@"facebook"]) {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        
        [login logOut];
    }
    else if([sns isEqualToString:@"twitter"]) {
        TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
        NSString *userID = store.session.userID;
        
        [store logOutUserID:userID];
    }
    
    ///////////////////////////////////////////////////
    // FOR RC SDK
    ///////////////////////////////////////////////////

    [[RCSDK sharedInstance] leave:^(NSString *response, NSError *error) {
            if(response) {
                NSLog(@"Calling RANK.CLOUD 'leave' module succeeded. %@", response);
            }
            
            if(error) {
                NSLog(@"Calling RANK.CLOUD 'leave' module failed. %@", [error localizedDescription]);
            }
        }
    ];
    
    ///////////////////////////////////////////////////
    
    NSString *appendText = @"";
    appendText = [appendText stringByAppendingString:@"\n---------------------------"];
    appendText = [appendText stringByAppendingString:@"\nCalled RANK.CLOUD 'leave' module."];
    appendText = [appendText stringByAppendingString:@"\n---------------------------\n"];
    
    _logText.text = [_logText.text stringByAppendingString:appendText];
    [_logText scrollRangeToVisible:NSMakeRange([_logText.text length], 0)];
    
    // Clear session value.
    [Common clearSession];
    [Common switchView:VIEW_TYPE_LOGIN];
}

- (IBAction)pushOn:(id)sender {
    ///////////////////////////////////////////////////
    // FOR RC SDK
    ///////////////////////////////////////////////////
    
    [[RCSDK sharedInstance] pushOn:^(NSString *response, NSError *error) {
            if(response) {
                NSLog(@"RANK.CLOUD's smart push [ON]. %@", response);
            }
            
            if(error) {
                NSLog(@"Failed to turn on RANK.CLOUD's smart push. %@", [error localizedDescription]);
            }
        }
    ];
    
    ///////////////////////////////////////////////////
    
    NSString *appendText = @"";
    appendText = [appendText stringByAppendingString:@"\n---------------------------"];
    appendText = [appendText stringByAppendingString:@"\nCalled RANK.CLOUD 'pushOn' module."];
    appendText = [appendText stringByAppendingString:@"\n---------------------------\n"];
    
    _logText.text = [_logText.text stringByAppendingString:appendText];
    [_logText scrollRangeToVisible:NSMakeRange([_logText.text length], 0)];
}

- (IBAction)pushOff:(id)sender {
    ///////////////////////////////////////////////////
    // FOR RC SDK
    ///////////////////////////////////////////////////
    
    [[RCSDK sharedInstance] pushOff:^(NSString *response, NSError *error) {
            if(response) {
                NSLog(@"RANK.CLOUD's smart push [OFF]. %@", response);
            }
            
            if(error) {
                NSLog(@"Failed to turn off RANK.CLOUD's smart push. %@", [error localizedDescription]);
            }
        }
    ];
    
    ///////////////////////////////////////////////////
    
    NSString *appendText = @"";
    appendText = [appendText stringByAppendingString:@"\n---------------------------"];
    appendText = [appendText stringByAppendingString:@"\nCalled RANK.CLOUD 'pushOff' module."];
    appendText = [appendText stringByAppendingString:@"\n---------------------------\n"];
    
    _logText.text = [_logText.text stringByAppendingString:appendText];
    [_logText scrollRangeToVisible:NSMakeRange([_logText.text length], 0)];
}
@end
