//
//  NaviViewController.m
//  GetRide
//
//  Created by 余佳恆 on 2015/11/21.
//  Copyright © 2015年 CHIA HENG YU. All rights reserved.
//

#import "NaviViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse.h>


@interface NaviViewController ()<MKMapViewDelegate,CLLocationManagerDelegate>

{
    __weak IBOutlet UITextField *targetTextField;
    CLLocation *currentLocation;
    CLLocationManager *locationManager;
    CLLocationSpeed *locationSpeed;
    CLLocation *startingPoint;
    BOOL isFirstLocationReceived;
}
@property (weak, nonatomic) IBOutlet MKMapView *myMapView;

@end

@implementation NaviViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    [self getFriendLocation];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawPolyLine) name:@"updateLocation" object:nil];

//    NSLog(@"%@", _locationArray);
    
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



- (void) regioncenter {
    if (isFirstLocationReceived == false) {
        MKCoordinateRegion region = _myMapView.region;  // 將藍點移到地圖中心
        region.center = currentLocation.coordinate;
        region.span.latitudeDelta = 0.01;
        region.span.longitudeDelta = 0.01;
        [_myMapView setRegion:region animated:true];
        
        isFirstLocationReceived = true;
    }
}


// 下載位置並顯示在地圖上
- (void) getFriendLocation {
    
    PFQuery *friendLocation = [PFQuery queryWithClassName:@"MapLocation"];
    
    [friendLocation findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
     {
//         NSMutableArray *parseAnnotationArray = [NSMutableArray new];

         for (PFObject *object in objects)
         {
             NSNumber *friendLat = object[@"currentLatitude"];
             NSNumber *friendLon = object[@"currentLongitude"];

             PFObject* userObject = object[@"userKeyPointer"];
             NSLog(@"userKeyPointer人名: %@",userObject);
             
             [userObject fetch];
             NSString *userName = userObject[@"username"];
             NSString *userEmail = userObject[@"email"];
             
             
             MKPointAnnotation *annotaion = [[MKPointAnnotation alloc]init];
             annotaion.coordinate = CLLocationCoordinate2DMake([friendLat doubleValue], [friendLon doubleValue]);
             annotaion.title = [NSString stringWithFormat:@"%@",userName];
             annotaion.subtitle =[NSString stringWithFormat:@"%@",userEmail];

             [self.myMapView addAnnotation:annotaion];
         }
     }];
}


// 實作
- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    // 自己位置不顯示
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }

    MKPinAnnotationView *view = (MKPinAnnotationView *)
    [mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
    if (view == nil) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
    }
    
    view.canShowCallout = true;
    
    
    return view;
}



//軌跡
-(void)drawPolyLine {
    CLLocationCoordinate2D coordList[_locationArray.count];
    for (int i = 0; i < _locationArray.count ; i++) {
        CLLocation *location = _locationArray[i];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
        coordList[i] = coord;
    }
    
    MKPolyline *line = [MKPolyline polylineWithCoordinates:coordList count:_locationArray.count];
    [_myMapView addOverlay:line];
}
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor redColor];
    renderer.lineWidth = 4.0;
    
    return renderer;
}



- (IBAction)mapTypeChanged:(id)sender {
    NSInteger targetIndex = [sender selectedSegmentIndex];
    
    switch (targetIndex) {
        case 0:
            _myMapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            _myMapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            _myMapView.mapType = MKMapTypeHybrid;
            break;
        default:
            break;
    }
}
- (IBAction)userTackingModeChanged:(id)sender {
    NSInteger targetIndex = [sender selectedSegmentIndex];
    
    switch (targetIndex) {
        case 0:
            _myMapView.userTrackingMode = MKUserTrackingModeNone;
            break;
        case 1:
            _myMapView.userTrackingMode = MKUserTrackingModeFollow;
            break;
        case 2:
            _myMapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
            break;
        default:
            break;
    }
}

// 搜尋地址
- (IBAction)targetTextFieldReturn:(id)sender {
    //地址查詢經緯度
    CLGeocoder *geocoder = [CLGeocoder new];
    
    [geocoder geocodeAddressString:targetTextField.text completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"Geocode Fail: %@",error.description);
            return;
        } else if (placemarks && placemarks.count > 0) {
            CLPlacemark *targetPlaceMark = placemarks[0];
            NSLog(@"Found at : %.6f,%.6f",targetPlaceMark.location.coordinate.latitude,targetPlaceMark.location.coordinate.longitude);
            
            // 將經緯度移到地圖中心
            // Add Annotation
            MKCoordinateRegion region = _myMapView.region;  // 將藍點移到地圖中心
            region.center = targetPlaceMark.location.coordinate;
            region.span.latitudeDelta = 0.01;
            region.span.longitudeDelta = 0.01;
            [_myMapView setRegion:region animated:true];
            
            // Add 大頭針Annotation
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = targetPlaceMark.location.coordinate.latitude;
            coordinate.longitude = targetPlaceMark.location.coordinate.longitude;
            
            // 設定大頭針
            MKPointAnnotation *annotation = [MKPointAnnotation new];
            annotation.title = targetTextField.text;
            annotation.coordinate = coordinate;
            
            [_myMapView addAnnotation:annotation];
        }
    }];
}

- (IBAction)dismissMap:(id)sender {
    [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
}

@end
