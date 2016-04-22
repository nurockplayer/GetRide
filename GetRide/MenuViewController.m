//
//  MenuViewController.m
//  GetRide
//
//  Created by 余佳恆 on 2015/11/29.
//  Copyright © 2015年 CHIA HENG YU. All rights reserved.
//

#import "MenuViewController.h"
#import <Parse/Parse.h>
#import <Bolts/Bolts.h>

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)dismissMap:(id)sender {
    [PFUser logOut];
    PFUser *currentUser = [PFUser currentUser]; // this will now be nil
    [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
    
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self showViewController:vc sender:self];
}
@end
