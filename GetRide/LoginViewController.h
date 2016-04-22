//
//  LoginViewController.h
//  GetRide
//
//  Created by 余佳恆 on 2015/11/21.
//  Copyright © 2015年 CHIA HENG YU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>


@interface LoginViewController : UIViewController
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccount *facebookAccount;


@end
