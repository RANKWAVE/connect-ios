//
//  Common.m
//  Rankwave
//
//  Created by HyoungEun Kim on 2015. 9. 24..
//  Copyright © 2015-present Rankwave Co.,Ltd. All rights reserved.
//

#import "Common.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "ServiceViewController.h"

@implementation Common

NSString* LOG_LINE = @"====================================";
NSString* BODY_LINE = @"------------------------------------";


+ (void)avoidUnbalancedProblemForSwitchingView:(NSNumber *)type {
    int typeView = type.intValue;
    
    UIViewController *controller = nil;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    UINavigationController *navigationController = [appDelegate navigationController];
    
    switch (typeView) {
        case VIEW_TYPE_LOGIN :
            [navigationController popToRootViewControllerAnimated:YES];
            return; // Needless push view controller. The root is login view controller.
        case VIEW_TYPE_SERVICE :
            controller = [[ServiceViewController alloc] init];
            break;
    }
    
    [navigationController popToRootViewControllerAnimated:NO];
    [navigationController pushViewController:controller animated:NO];
}

+ (void)switchView:(int)typeView {
    // For avoiding problem of unbalanced calls to begin/end appearance transitions, switching view with some delay.
    NSNumber *type = [NSNumber numberWithInt:typeView];
    [self performSelector:@selector(avoidUnbalancedProblemForSwitchingView:) withObject:type afterDelay:0.50];
}

+ (NSString *)makeLog:(NSString *)header withBodyStr:(NSString *)body {
    NSString *log = [[NSString alloc] initWithFormat:@"\n%@\n[%@]\n%@\n%@\n%@", LOG_LINE, header, BODY_LINE, body, LOG_LINE];
    return log;
}

+ (NSString *)makeLog:(NSString *)header withBodyDic:(NSDictionary *)body {
    NSString *log = [[NSString alloc] initWithFormat:@"\n%@\n[%@]\n%@\n%@\n%@", LOG_LINE, header, BODY_LINE, body, LOG_LINE];
    return log;
}

+ (NSString *)makeLog:(NSString *)header withBodyJson:(NSDictionary *)body {
    NSString *log = [[NSString alloc] initWithFormat:@"\n%@\n[%@]\n%@\n%@\n%@",
                                    LOG_LINE, header, BODY_LINE, [Common dicToJsonString:body], LOG_LINE];
    return log;
}

+ (void)alert:(NSString *)msg {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", nil)
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

+ (NSString *)dicToJsonString:(NSDictionary *)dic {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    if(!jsonData) {
        return nil;
    }
    else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

+ (void)saveSessionID:(NSString *)loginID withSNS:(NSString *)sns
                                                withToken:(NSString *)token withTokenSecret:(NSString *)tokenSecret {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    if(loginID) [userDefault setObject:loginID forKey:@"session_login_id"];
    if(sns) [userDefault setObject:sns forKey:@"session_sns"];
    if(token) [userDefault setObject:token forKey:@"session_token"];
    if(tokenSecret)[userDefault setObject:tokenSecret forKey:@"session_token_secret"];
}

+ (void)clearSession {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    [userDefault removeObjectForKey:@"session_login_id"];
    [userDefault removeObjectForKey:@"session_sns"];
    [userDefault removeObjectForKey:@"session_token"];
    [userDefault removeObjectForKey:@"session_token_secret"];
}

+ (NSString *)getLoginIDFromSession {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"session_login_id"];
}

+ (NSString *)getSNSFromSession {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"session_sns"];
}

+ (NSString *)getTokenFromSession {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"session_token"];
}

+ (NSString *)GetTokenSecretFromSession {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"session_token_secret"];
}

@end
