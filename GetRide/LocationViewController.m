//
//  LocationViewController.m
//  GetRide
//
//  Created by 余佳恆 on 2015/11/26.
//  Copyright © 2015年 CHIA HENG YU. All rights reserved.
//

#import "LocationViewController.h"

@interface LocationViewController ()<MKMapViewDelegate,CLLocationManagerDelegate>{

    CLLocationCoordinate2D _coordinate;


}

@property (weak, nonatomic) IBOutlet UITextField *targetTextField;
@property (weak, nonatomic) IBOutlet MKMapView *myMapView;

@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    CLLocationManager* manager;
    if (manager==nil) {
        manager = [[CLLocationManager alloc]init];
        if ([manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [manager requestWhenInUseAuthorization];
            
            //设置代理（CLLocationManagerDelegate）
            manager.delegate = self;
            
            //设置定位精度
            manager.desiredAccuracy = kCLLocationAccuracyBest;
            
            //设置距离筛选
            manager.distanceFilter = 100;
            
        }
    }
        [manager startUpdatingLocation];
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



- (void) getLocation
{
    myLocationList = [NSMutableArray new];
    locationManager = [[CLLocationManager alloc] init];
    
    // chechk locationManager support WhenInUse 否則iOS8以前會當掉
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    
    //    locationManager.desiredAccuracy = kCLLocationAccuracyBest;  //精確度
    //    // locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    //    locationManager.activityType = CLActivityTypeFitness;  //預設導航模式
    
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    _coordinate.latitude = userLocation.location.coordinate.latitude;
    _coordinate.longitude = userLocation.location.coordinate.longitude;
    
    [self setMapRegionWithCoordinate:_coordinate];
}

- (void)setMapRegionWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    MKCoordinateRegion region;
    
    region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(.1, .1));
    MKCoordinateRegion adjustedRegion = [_myMapView regionThatFits:region];
    [_myMapView setRegion:adjustedRegion animated:YES];
}

-(IBAction)returnButton:(id)sender{

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    NSString *addressString = _targetTextField.text; // Address Here
    
    [geocoder geocodeAddressString:addressString
                 completionHandler:^(NSArray *placemarks, NSError *error) {
                     
                     if (error) {
                         NSLog(@"Geocode failed with error: %@", error);
                         return;
                     }
                     
                     if (placemarks && placemarks.count > 0)
                     {
                         CLPlacemark *placemark = placemarks[0];
                         NSLog(@"Found at : %.6f,%.6f",placemark.location.coordinate.latitude,placemark.location.coordinate.longitude);
                         // 將經緯度移到地圖中心
                         // Add Annotation
                         MKCoordinateRegion region = _myMapView.region;  // 將藍點移到地圖中心
                         region.center = placemark.location.coordinate;
                         region.span.latitudeDelta = 0.01;
                         region.span.longitudeDelta = 0.01;
                         [_myMapView setRegion:region animated:true];
                         
                         // Add 大頭針Annotation
                         CLLocationCoordinate2D coordinate;
                         coordinate.latitude = placemark.location.coordinate.latitude;
                         coordinate.longitude = placemark.location.coordinate.longitude;
                         
                         // 設定大頭針
                         MKPointAnnotation *annotation = [MKPointAnnotation new];
                         annotation.title = _targetTextField.text;
                         annotation.coordinate = coordinate;
                         
                         [_myMapView addAnnotation:annotation];
                         
                         CLLocationCoordinate2D fromCoordinate = _coordinate;
                         
                         
                         CLLocationCoordinate2D toCoordinate   = CLLocationCoordinate2DMake(coordinate.latitude,
                                                                                            coordinate.longitude);
                         
                         MKPlacemark *fromPlacemark = [[MKPlacemark alloc] initWithCoordinate:fromCoordinate
                                                                            addressDictionary:nil];
                         
                         MKPlacemark *toPlacemark   = [[MKPlacemark alloc] initWithCoordinate:toCoordinate
                                                                            addressDictionary:nil];
                         
                         MKMapItem *fromItem = [[MKMapItem alloc] initWithPlacemark:fromPlacemark];
                         
                         MKMapItem *toItem   = [[MKMapItem alloc] initWithPlacemark:toPlacemark];
                         
                         [self findDirectionsFrom:fromItem
                                               to:toItem];
                         
                     }
                 }];

}

// 搜尋地址
//- (IBAction)goBtnPressed:(id)sender {
//    
//    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
//    
//    NSString *addressString = _targetTextField.text; // Address Here
//    
//    [geocoder geocodeAddressString:addressString
//                 completionHandler:^(NSArray *placemarks, NSError *error) {
//                     
//                     if (error) {
//                         NSLog(@"Geocode failed with error: %@", error);
//                         return;
//                     }
//                     
//                     if (placemarks && placemarks.count > 0)
//                     {
//                         CLPlacemark *placemark = placemarks[0];
//                        NSLog(@"Found at : %.6f,%.6f",placemark.location.coordinate.latitude,placemark.location.coordinate.longitude);
//                         // 將經緯度移到地圖中心
//                         // Add Annotation
//                         MKCoordinateRegion region = _myMapView.region;  // 將藍點移到地圖中心
//                         region.center = placemark.location.coordinate;
//                         region.span.latitudeDelta = 0.01;
//                         region.span.longitudeDelta = 0.01;
//                         [_myMapView setRegion:region animated:true];
//                         
//                         // Add 大頭針Annotation
//                         CLLocationCoordinate2D coordinate;
//                         coordinate.latitude = placemark.location.coordinate.latitude;
//                         coordinate.longitude = placemark.location.coordinate.longitude;
//                         
//                         // 設定大頭針
//                         MKPointAnnotation *annotation = [MKPointAnnotation new];
//                         annotation.title = _targetTextField.text;
//                         annotation.coordinate = coordinate;
//                         
//                         [_myMapView addAnnotation:annotation];
//                         
//                         CLLocationCoordinate2D fromCoordinate = _coordinate;
//                         
//                         
//                         CLLocationCoordinate2D toCoordinate   = CLLocationCoordinate2DMake(coordinate.latitude,
//                                                                                            coordinate.longitude);
//                         
//                         MKPlacemark *fromPlacemark = [[MKPlacemark alloc] initWithCoordinate:fromCoordinate
//                                                                            addressDictionary:nil];
//                         
//                         MKPlacemark *toPlacemark   = [[MKPlacemark alloc] initWithCoordinate:toCoordinate
//                                                                            addressDictionary:nil];
//                         
//                         MKMapItem *fromItem = [[MKMapItem alloc] initWithPlacemark:fromPlacemark];
//                         
//                         MKMapItem *toItem   = [[MKMapItem alloc] initWithPlacemark:toPlacemark];
//                         
//                         [self findDirectionsFrom:fromItem
//                                               to:toItem];
//                         
//                     }
//                 }];
//    
//}

#pragma mark - Private

- (void)findDirectionsFrom:(MKMapItem *)source
                        to:(MKMapItem *)destination
{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = source;
    request.destination = destination;
    request.requestsAlternateRoutes = YES;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         
         if (error) {
             
             NSLog(@"error:%@", error);
         }
         else {
             
             MKRoute *route = response.routes[0];
             
             [self.myMapView addOverlay:route.polyline];
         }
     }];
}

#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.lineWidth = 5.0;
    renderer.strokeColor = [UIColor purpleColor];
    return renderer;
}

- (IBAction)dismissMap:(id)sender {
    [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
}

@end
