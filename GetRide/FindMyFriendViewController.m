//
//  FindMyFriendViewController.m
//  GetRide
//
//  Created by 余佳恆 on 2015/11/21.
//  Copyright © 2015年 CHIA HENG YU. All rights reserved.
//

#import "FindMyFriendViewController.h"
#import <MapKit/MapKit.h>


@interface FindMyFriendViewController ()
{
    BOOL isFirstLocationReceived;
}
@property (weak, nonatomic) IBOutlet MKMapView *myMapView;

@end

@implementation FindMyFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
    if (isFirstLocationReceived == false) {
        MKCoordinateRegion region = _myMapView.region;  // 將藍點移到地圖中心
//        region.center = currentLocation.coordinate;
        region.span.latitudeDelta = 0.01;
        region.span.longitudeDelta = 0.01;
        [_myMapView setRegion:region animated:true];
        
        isFirstLocationReceived = true;
    }
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


- (IBAction)logOutBtnPressed:(id)sender {
    [PFUser logOut];
    //    PFUser *currentUser = [PFUser currentUser]; // this will now be nil
    [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
}


- (void) Parse {
    
}

@end
