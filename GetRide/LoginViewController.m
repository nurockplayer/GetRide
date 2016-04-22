//
//  LoginViewController.m
//  GetRide
//
//  Created by 余佳恆 on 2015/11/21.
//  Copyright © 2015年 CHIA HENG YU. All rights reserved.
//

#import "LoginViewController.h"
#import "indexViewController.h"
#import <FBSDKLoginKit/FBSDKLoginButton.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>


@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


-(void)viewDidAppear:(BOOL)animated
{
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser.objectId.length > 0) {
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"indexViewController"];
        [self showViewController:vc sender:self];
    }
    
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    // Optional: Place the button in the center of your view.
    loginButton.center = self.view.center;
//    [self.view addSubview:loginButton];
    
    loginButton.readPermissions =
    @[@"public_profile", @"email", @"user_friends"];
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
- (IBAction)loginBtnPressed:(id)sender {
    [PFUser logInWithUsernameInBackground:self.userNameTextField.text
                                 password:self.passwordTextField.text
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            NSLog(@"LoginSuccess");
                                            UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];

                                            [self presentViewController:vc animated:YES completion:nil];
                                        } else {
                                            NSLog(@"Login Failed");
                                            self.userNameTextField.text = @"登入失敗";
                                            self.passwordTextField.text = nil;
                                        }
                                    }];
}

-(IBAction)backToLogin:(UIStoryboardSegue *) segue {
    NSLog(@"back to Login");
}

- (IBAction)doEditFieldDone:(id)sender {
    [sender resignFirstResponder];
}


- (IBAction)facebookFetchData:(UIButton *)button
{
    if(self.accountStore == nil){
        self.accountStore = [[ACAccountStore alloc] init];
    }
    ACAccountType *facebookAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSString *facebookAppIDStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"];
    
    NSDictionary *options = @{
                              ACFacebookAppIdKey : facebookAppIDStr,
                              ACFacebookPermissionsKey : @[@"email", @"public_profile"],
                              ACFacebookAudienceKey : ACFacebookAudienceEveryone}; // Needed only when write permissions are requested
    
    [self.accountStore requestAccessToAccountsWithType:facebookAccountType options:options
                                            completion:^(BOOL granted, NSError *error) {
                                                if (granted)
                                                {
                                                    NSArray *accounts = [self.accountStore
                                                                         accountsWithAccountType:facebookAccountType];
                                                    self.facebookAccount = [accounts lastObject];
                                                    NSLog(@"facebookAccount oauthToken: %@", self.facebookAccount.credential.oauthToken);
                                                } else {
                                                    NSLog(@"error: %@", error);
                                                    // Fail gracefully...
                                                }
                                            }];
}
@end
