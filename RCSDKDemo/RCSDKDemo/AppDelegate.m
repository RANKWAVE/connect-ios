//
//  AppDelegate.m
//  RCSDKDemo
//
//  Created by HyoungEun Kim on 2015. 9. 24..
//  Copyright © 2015-present Rankwave Co.,Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"

#import "Common.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <RCSDKCoreKit/RCSDKCoreKit.h>

#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>

#import <KakaoOpenSDK/KakaoOpenSDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Register User notification settings.
    if([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        // iOS 8 Notifications
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else {
        // iOS < 8 Notifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    
    // Initialize Badge number & notifications.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // LoginView will be shown at first time.
    LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    self.window.rootViewController = self.navigationController;
    
    [self.window makeKeyAndVisible];
        
    ///////////////////////////////////////////////////
    // FOR RC SDK
    ///////////////////////////////////////////////////
    
    // For test, Setting the idle time value to 10 seconds.
    [[RCSDK sharedInstance] setIdleTime:10];
    
    [[RCSDK sharedInstance] sdkInitialize:launchOptions response:^(NSString *response, NSError *error) {
        if(response) {
            NSLog(@"SDK initializing succeed.\n%@", response);
        }
        
        if(error) {
            NSLog(@"SDK initializing failed.\n%@", [error localizedDescription]);
        }
    }];
    ///////////////////////////////////////////////////
    [[Twitter sharedInstance] startWithConsumerKey:@"hclIiq4u3s3PT6qXeCIGM3hJy"
                                    consumerSecret:@"9ZydYUpC9RaH5DMeUkNkOv07lJcSJbIlpA9lvsdWqLtn891zOf"];
    [Fabric with:@[[Twitter sharedInstance]]];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kakaoSessionDidChangeWithNotification:)
                                                 name:KOSessionDidChangeNotification
                                               object:nil];
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    ///////////////////////////////////////////////////
    // FOR RC SDK
    ///////////////////////////////////////////////////
    
    NSMutableString *pushToken = [NSMutableString string];
    const unsigned char* ptr = (const unsigned char*) [deviceToken bytes];
    
    for(int i = 0 ; i < 32 ; i++) {
        [pushToken appendFormat:@"%02x", ptr[i]];
    }
    
    [[RCSDK sharedInstance] registerDeviceToken:pushToken response:^(NSString *response, NSError *error) {
        if(response) {
            NSLog(@"Registering device succeed.\n%@", response);
        }
        
        if(error) {
            NSLog(@"Registering device failed.\n%@", [error localizedDescription]);
        }
    }];
    
    ///////////////////////////////////////////////////
    
    NSLog(@"%@", [Common makeLog:@"Push token" withBodyStr:pushToken]);
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error {
    NSLog(@"Failed to register for remote notifications.\n%@", [error localizedDescription]);
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    if([KOSession isKakaoAccountLoginCallback:url]) {
        return [KOSession handleOpenURL:url];
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
            ];
}

- (void)kakaoSessionDidChangeWithNotification:(NSNotification *)notification
{
    if(![[KOSession sharedSession] isOpen]) {
        // do something for unauthenticated user
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // An observer in RCSDKCoreKit will process current notifications.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RC_Push_Notification" object:nil userInfo:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[RCSDK sharedInstance] activateApp:FALSE];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
    [KOSession handleDidBecomeActive];
    [[RCSDK sharedInstance] activateApp:TRUE];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
