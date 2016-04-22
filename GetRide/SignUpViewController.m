//
//  SignUpViewController.m
//  GetRideSwift
//
//  Created by 余佳恆 on 2015/11/16.
//  Copyright © 2015年 CHIA HENG YU. All rights reserved.
//

#import "SignUpViewController.h"
#import <Parse/Parse.h>
#import <Bolts/Bolts.h>

@interface SignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *bikeTextField;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    NSLog(@"viewDidDisappear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doEditFieldDone:(id)sender {
    [sender resignFirstResponder];
}
- (IBAction)signUpBtnPressed:(id)sender {
    
    PFUser *user = [PFUser user];
    user.email = self.emailTextField.text;
    user.username = self.userNameTextField.text;
    user.password = self.passwordTextField.text;

    user[@"Bike"] = self.bikeTextField.text;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"LoginSuccess");
            [user saveInBackground];
            [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];

        } else {
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"%@",errorString);
            //            NSLog(@"%@",[error userInfo]);
        }
    }];

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
