//
//  ServiceViewController.h
//  RCSDKDemo
//
//  Created by HyoungEun Kim on 2015. 9. 24..
//  Copyright © 2015-present Rankwave Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServiceViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UITextView *logText;

- (IBAction)logout:(id)sender;
- (IBAction)leave:(id)sender;
- (IBAction)pushOn:(id)sender;
- (IBAction)pushOff:(id)sender;

@end
