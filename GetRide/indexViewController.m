//
//  indexViewController.m
//  GetRide
//
//  Created by 余佳恆 on 2015/11/21.
//  Copyright © 2015年 CHIA HENG YU. All rights reserved.
//

#import "indexViewController.h"

@interface indexViewController ()

@end

@implementation indexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    PFUser *currentUser = [PFUser currentUser];
    UIViewController *vc;
    if (currentUser.objectId.length > 0) {
        vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
    } else {
//        vc = [self.storyboard instantiateViewControllerWithIdentifier:@"indexNaviViewController"];
        vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];

    }
    [self showViewController:vc sender:self];
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

@end
