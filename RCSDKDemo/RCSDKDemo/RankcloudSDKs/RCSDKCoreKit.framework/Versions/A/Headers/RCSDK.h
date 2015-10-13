//  Created by HyoungEun Kim on 2015. 9. 24..
//  Copyright © 2015-present Rankwave Co.,Ltd. All rights reserved.


#import <Foundation/Foundation.h>

@import UIKit;

#ifndef _RES_BLOCK_DEFINED
#define _RES_BLOCK_DEFINED

typedef void (^ResponseBlock)(NSString *response, NSError *error);

#endif

@interface RCSDK : NSObject

+ (RCSDK *) sharedInstance;

#pragma mark Initializing
- (void) sdkInitialize:(NSDictionary *)launchOptions response:(ResponseBlock)resBlock;

#pragma mark Login / Logout / Leave
- (void) loginWithFacebookID:(NSString *)snsID withToken:(NSString *)token response:(ResponseBlock) resBlock;
- (void) loginWithTwitterID:(NSString *)snsID withToken:(NSString *)token withTokenSecret:(NSString *)secret response:(ResponseBlock)resBlock;
- (void) loginWithEmail:(NSString *)email response:(ResponseBlock)resBlock;
- (void) logout:(ResponseBlock)resBlock;
- (void) leave:(ResponseBlock)resBlock;

#pragma mark Push
- (void) registerDeviceToken:(NSString *)pushToken response:(ResponseBlock)resBlock;
- (void) pushOn:(ResponseBlock)resBlock;
- (void) pushOff:(ResponseBlock)resBlock;

#pragma mark App state
- (void) activateApp:(BOOL)flag;
@end
