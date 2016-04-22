//
//  LocationViewController.h
//  GetRide
//
//  Created by 余佳恆 on 2015/11/26.
//  Copyright © 2015年 CHIA HENG YU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <Bolts/Bolts.h>
#import <FMDatabase.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@interface LocationViewController : UIViewController
{
    CLLocationManager *locationManager;
    
    NSMutableArray *myLocationList; //軌跡用
    CLLocation *currentLocation;
}
- (void) getLocation;
-(IBAction)returnButton:(id)sender;

@property (strong, nonatomic) CLLocationManager *locationManager;
@end
