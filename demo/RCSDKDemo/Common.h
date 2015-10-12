//
//  Common.h
//  Rankwave
//
//  Created by HyoungEun Kim on 2015. 9. 24..
//  Copyright © 2015-present Rankwave Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

// Defiition of transaction ID
#define VIEW_TYPE_LOGIN             0
#define VIEW_TYPE_SERVICE           1

@interface Common : NSObject

+ (void)avoidUnbalancedProblemForSwitchingView:(NSNumber *)type;
+ (void)switchView:(int)typeView;

+ (NSString *)makeLog:(NSString *)header withBodyStr:(NSString *)body;
+ (NSString *)makeLog:(NSString *)header withBodyDic:(NSDictionary *)body;
+ (NSString *)makeLog:(NSString *)header withBodyJson:(NSDictionary *)body;

+ (void)alert:(NSString *)msg;
+ (NSString *)dicToJsonString:(NSDictionary *)dic;

+ (NSString *)getLoginIDFromSession;
+ (NSString *)getSNSFromSession;
+ (NSString *)getTokenFromSession;
+ (NSString *)GetTokenSecretFromSession;

+ (void)saveSessionID:(NSString *)loginID withSNS:(NSString *)sns withToken:(NSString *)token withTokenSecret:(NSString *)tokenSecret;
+ (void)clearSession;
@end
