//
//  DetailViewController.m
//  GetRide
//
//  Created by 余佳恆 on 2015/11/26.
//  Copyright © 2015年 CHIA HENG YU. All rights reserved.
//

#import "DetailViewController.h"
#import <FMDatabase.h>
#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <Social/Social.h>

@interface DetailViewController () <MKMapViewDelegate,CLLocationManagerDelegate>
{
    NSMutableArray *datas;
    NSString *dbFileNamePath;   //路徑
    NSMutableArray *myLocationListdata;
    NSArray *myLocationListAr;
    UIImage *screenImage;
    
    CGFloat centerLatitude;
    CGFloat centerLongitude;
}
@property (weak, nonatomic) IBOutlet MKMapView *myMapView;
@property (weak, nonatomic) IBOutlet UILabel *TimeLabel;        //顯示時間
@property (weak, nonatomic) IBOutlet UILabel *sumDistanceLabel; //移動距離
@property (weak, nonatomic) IBOutlet UILabel *alwaySpeedLabel;  //總平均速度
@property (weak, nonatomic) IBOutlet UILabel *upSpeedLabel;

@property (weak, nonatomic) IBOutlet UIImageView *image;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    MapViewController *mapVC = [MapViewController new];
    datas = mapVC.getFileList;
    
    NSString * documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0];

    dbFileNamePath = [documentsPath stringByAppendingPathComponent:@"Mapsqlite.db"];
    
//    NSLog(@"dbFileNamePath: %@",dbFileNamePath);

    [self queryFileList];
    [self regionCenter];
    [self drawPolyLine];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) regionCenter {
    MKCoordinateRegion region = _myMapView.region;  // 移到地圖中心
    NSLog(@"%f,%f",centerLatitude,centerLongitude);
    region.center.latitude = centerLatitude;
    region.center.longitude = centerLongitude;
    region.span.latitudeDelta = 0.0025;
    region.span.longitudeDelta = 0.0025;
    [_myMapView setRegion:region animated:true];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)queryFileList{
    
    FMDatabase * db = [FMDatabase databaseWithPath:dbFileNamePath];
    if([db open]){
        NSString * sql = [NSString stringWithFormat:@"SELECT * FROM Mapsample_table WHERE uid = %i;",self.routeID.intValue];
        FMResultSet * result = [db executeQuery:sql];
        if(_objects == nil){
            _objects = [NSMutableArray new];
        }
        // 透過while來掃所有的資料內容 一次一筆
        while ([result next]) {
            // 利用欄位來查詢
            NSInteger uid = [result intForColumn:@"uid"];
            NSString * avgSpeedNs = [result stringForColumn:@"avgSpeed"];
            NSString * alwaySpeedNs = [result stringForColumn:@"alwaySpeed"];
            NSString * allsumDistanceNs = [result stringForColumn:@"allsumDistance"];
            NSString * upSpeedNs = [result stringForColumn:@"upSpeed"];
            NSString * adddatetime = [result stringForColumn:@"adddatetime"];
            NSString * hour = [result stringForColumn:@"hour"];
            NSString * minute = [result stringForColumn:@"minute"];
            NSString * second = [result stringForColumn:@"second"];
            NSData * myLocationListdata = [result dataForColumn:@"myLocationList"];
            NSString *centerLatitudeDB = [result stringForColumn:@"centerLatitude"];
            NSLog(@"%@",centerLatitudeDB);
            centerLatitude = (CGFloat)[centerLatitudeDB floatValue];
            NSString *centerLongitudeDB = [result stringForColumn:@"centerLongitude"];
            NSLog(@"%@",centerLongitudeDB);
            centerLongitude = (CGFloat)[centerLongitudeDB floatValue];
            //image轉成imageData
            //            UIImage * image = [UIImage imageWithData:imageData];
            myLocationListAr = [NSKeyedUnarchiver unarchiveObjectWithData:myLocationListdata];

//            NSLog(@"%ld,%@,%@,%@,%@,%@,%@,%@,%@,%@",uid,avgSpeedNs,alwaySpeedNs,allsumDistanceNs,upSpeedNs,adddatetime,hour,minute,second,myLocationListAr);
            
//            [_objects addObject:adddatetime];
            
            _sumDistanceLabel.text = [NSString stringWithFormat:@"%@ km",allsumDistanceNs];
//            _TimeLabel.text = adddatetime;
            
            _alwaySpeedLabel.text = [NSString stringWithFormat:@"%@ km/h",alwaySpeedNs];
            _upSpeedLabel.text = [NSString stringWithFormat:@"%@ km/h",upSpeedNs];
//            myLocationListdata = myLocationListAr;
            self.TimeLabel.text = [NSString stringWithFormat:@"%@:%@:%@", hour, minute, second];
        }
        [db close];
        
    }
}



//軌跡
-(void)drawPolyLine {
    CLLocationCoordinate2D coordList[myLocationListAr.count];
    for (int i = 0; i < myLocationListAr.count ; i++) {
        CLLocation *location = myLocationListAr[i];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
        coordList[i] = coord;
    }
    
    MKPolyline *line = [MKPolyline polylineWithCoordinates:coordList count:myLocationListAr.count];
    [_myMapView addOverlay:line];
}
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor redColor];
    renderer.lineWidth = 4.0;
    
    return renderer;
}



- (IBAction)dismissMap:(id)sender {
    [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
}

- (UIImage *) screenImage:(UIView *)view {
    UIGraphicsBeginImageContext(view.frame.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    screenImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return screenImage;
    
}


- (IBAction)shareWithFacebookButtonPressed:(id)sender {

    
    [self screenImage:self.view];
//    _image.image=screenImage;

    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        
//        NSLog(@"%@",screenImage);
        SLComposeViewController* viewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        NSString *string=@"Share with FB";
        [viewController setInitialText:string];
        [viewController addImage:screenImage];
       
//        [viewController addURL:[NSURL URLWithString:@"http://www.google.com"]];
        
        [self presentViewController:viewController animated:YES completion:nil];
        
    }
    
}



@end
