//
//  MapViewController.m
//  GetRideSwift
//
//  Created by 余佳恆 on 2015/11/16.
//  Copyright © 2015年 CHIA HENG YU. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "NaviViewController.h"


@interface MapViewController () <MKMapViewDelegate,CLLocationManagerDelegate>
{
    CLLocation *currentLocation;
    CLLocationManager *locationManager;
    NSMutableArray *myLocationList;
    CLLocationSpeed *locationSpeed;
    CLLocation *startingPoint;

    NSString *dbFileNamePath;   //路徑
    CLLocation *startPoint;
    NSTimer *timer;
    int showTimer;
    CGFloat avgSpeed;
    CGFloat logupSpeed;
    CGFloat allsumDistance;
    CGFloat alwaySpeed;
    BOOL startStop;
    NSString *hour;
    NSString *minute;
    NSString *second;
    BOOL speedBool;
    
    CGFloat oldSpeed;
    CGFloat oldSpeed2;
    CGFloat oldSpeed3;
    CGFloat oldSpeed4;
    
    NaviViewController *navi;
    
    CGFloat maxLatitude;
    CGFloat minLatitude;
    CGFloat maxLongitude;
    CGFloat minLongitude;
    BOOL minMax;
}
@property (readonly, nonatomic) CLLocationDistance altitude; // 海拔高度
@property (readonly, nonatomic) CLLocationSpeed speed;   // 速度 公尺/秒
@property (readonly, nonatomic) CLLocationSpeed upSpeed;
@property (nonatomic, retain) CLLocation *prevLocation;
@property (nonatomic, assign) CGFloat sumTime;
@property (nonatomic, assign) CGFloat sumDistance;

@property (weak, nonatomic) IBOutlet UILabel *altitudeLabel;    //顯示海拔
@property (weak, nonatomic) IBOutlet UILabel *TimeLabel;        //顯示時間
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;       //  當前速度
@property (weak, nonatomic) IBOutlet UILabel *avgSpeedLabel;    //平均速度
@property (weak, nonatomic) IBOutlet UILabel *alwaySpeedLabel;  //總平均速度
@property (weak, nonatomic) IBOutlet UILabel *sumDistanceLabel; //移動距離
@property (weak, nonatomic) IBOutlet UILabel *upSpeedLabel;

@property (weak, nonatomic) IBOutlet UIButton *startStopBtn;



// MKDirections Request;
//calculate ETAWithCompletionHandler;
@end

@implementation MapViewController


- (void)viewDidLoad {
    [super viewDidLoad];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)startStop:(id)sender {
    
    if (startStop == false) {
        startStop = true;
//        [self renew];
        [self.startStopBtn setImage:[UIImage imageNamed:@"StopBtn.png"] forState:UIControlStateNormal];
        myLocationList = [NSMutableArray new];
        // NSLog(@"%@",[PFUser currentUser]);
        
        locationManager = [[CLLocationManager alloc] init];
        // 檢查locationManager有沒有支援WhenInUse 否則iOS8以前會當掉
        if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [locationManager requestAlwaysAuthorization];
        }
        
        // 最簡單的locationManager的使用方式
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;  //精確度
        locationManager.activityType = CLActivityTypeFitness;  //預設導航模式
        locationManager.delegate = self;
        [locationManager startUpdatingLocation];    //Heading是羅盤用的
        
        
        // Prepare dbFileNamePath
        NSString * documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0];
        
        //stringByAppendingPathComponent 附加資料檔檔名sqlite.db
        dbFileNamePath = [documentsPath stringByAppendingPathComponent:@"Mapsqlite.db"];
        
        NSLog(@"dbFileNamePath: %@",dbFileNamePath);
        
        // Create DB File if necessary 檢查某個file存不存在
        if([[NSFileManager defaultManager]fileExistsAtPath:dbFileNamePath]==false){
            FMDatabase * db = [FMDatabase databaseWithPath:dbFileNamePath];
            // 如果第一次執行還是會幫我們自動開檔案可是檔案是空的
            if([db open]){
                BOOL success = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS Mapsample_table(uid integer primary key autoincrement,avgSpeed text,alwaySpeed text,allsumDistance text,upSpeed text,adddatetime text,hour text,minute text,second text,centerLatitude,centerLongitude,myLocationList blob);"];
                
                NSLog(@"Create Tabl %@",(success?@"Success":@"Failed."));
                [db close];
            }
        }
        [self queryFileList];
        
        

    } else if (startStop == true) {
        [self.startStopBtn setImage:[UIImage imageNamed:@"startBtn.png"] forState:UIControlStateNormal];

                startStop = false;
                minMax = true;
                [locationManager stopUpdatingLocation];
                [self saveToSQLite];
                NSLog(@"save success");
        
    }
    
    if ([timer isValid])
    {
        [timer invalidate];
    }else{
        //        showTimer = 0;
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    }
    
}

- (void) renew {

    
    [myLocationList removeAllObjects];
    [_objects removeAllObjects];
    _prevLocation = 0;
    currentLocation = 0;
    locationManager = 0;
    locationSpeed = 0;

    [myLocationList removeAllObjects];

    avgSpeed = 0.0;
    alwaySpeed = 0;
    allsumDistance = 0.0;

    logupSpeed = 0.0;
    _speed = 0;
    _sumTime = 0.0;
    _sumDistance = 0.0;
    hour = 0;
    minute = 0;
    second = 0;
    showTimer = 0;
    

    _speed = 0.0;
    
    hour = 0;
    minute = 0;
    second = 0;
    
    maxLatitude = 0;
    minLatitude = 0;
    maxLongitude = 0;
    minLongitude = 0;

}


-(void) updateTime:(NSTimer *)sender{

    showTimer++;
    NSInteger tempHour = showTimer / 3600;
    NSInteger tempMinute = showTimer / 60 - (tempHour * 60);
    NSInteger tempSecond = showTimer - (tempHour * 3600 + tempMinute * 60);
    
    hour = [[NSNumber numberWithInteger:tempHour] stringValue];
    minute = [[NSNumber numberWithInteger:tempMinute] stringValue];
    second = [[NSNumber numberWithInteger:tempSecond] stringValue];
//    NSString *hour = [[NSNumber numberWithInteger:tempHour] stringValue];
//    NSString *minute = [[NSNumber numberWithInteger:tempMinute] stringValue];
//    NSString *second = [[NSNumber numberWithInteger:tempSecond] stringValue];
    if (tempHour < 10) {
        hour = [@"0" stringByAppendingString:hour];
    }
    if (tempMinute < 10) {
        minute = [@"0" stringByAppendingString:minute];
    }
    if (tempSecond < 10) {
        second = [@"0" stringByAppendingString:second];
    }
    self.TimeLabel.text = [NSString stringWithFormat:@"%@:%@:%@", hour, minute, second];

}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */




// 取得位置
#pragma mark - CLLocationManager
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
    
    currentLocation = locations.lastObject; //拿出最後一個location
    [myLocationList addObject:currentLocation];
    
    [self segue];
    
    CLLocationDegrees currentLatitude = currentLocation.coordinate.latitude;   //緯度
    CLLocationDegrees currentLongitude = currentLocation.coordinate.longitude; //經度
    NSLog(@"Current Location: %f,%f",currentLatitude,currentLongitude);
    

    if (currentLatitude > maxLatitude) {
        maxLatitude = currentLatitude;
    }
    if (currentLatitude < minLatitude){
        minLatitude = currentLatitude;
    }
    if (currentLongitude > maxLongitude) {
        maxLongitude = currentLongitude;
    }
    if (currentLongitude < minLongitude) {
        minLongitude = currentLongitude;
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateLocation" object:nil];   //呼叫drawPoly開始持續畫軌跡
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"regioncenter" object:nil];     //藍點放置於中心
    [self updateLocationToParse];
    
    double delayInSeconds = 1.0; // 延遲時間
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self Information];

    });

}

- (void) updateLocationToParse {
    // 將經緯度上傳到Parse
    PFUser * user=[PFUser currentUser];
    PFQuery *mapQuery = [PFQuery queryWithClassName:@"MapLocation"];
    NSNumber *latitude = [NSNumber numberWithDouble:currentLocation.coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithDouble:currentLocation.coordinate.longitude];
    // 搜尋若欄位存在則更新 不存在則新建
    [mapQuery whereKey:@"userKeyPointer" equalTo:user];
    [mapQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if(object)
        {
            object[@"currentLatitude"] = latitude;
            object[@"currentLongitude"] = longitude;
            [object saveInBackground];
//            NSLog(@"refresh success");
        }
        else
        {
            PFObject *newMapLocationObject = [PFObject objectWithClassName:@"MapLocation"];
            newMapLocationObject[@"currentLatitude"] = latitude;
            newMapLocationObject[@"currentLongitude"] = longitude;
            newMapLocationObject[@"userKeyPointer"] = user;   //資料庫關聯
            [newMapLocationObject saveInBackground];
            NSLog(@"location Save.");
        }
    }];
}



- (void) Information {
    if(currentLocation.verticalAccuracy > 0)
    {
        NSLog(@"當前海拔高度：%.0f +/- %.0f 誤差",currentLocation.altitude,currentLocation.verticalAccuracy);
    }

    if(currentLocation.horizontalAccuracy < kCLLocationAccuracyHundredMeters)
    {
        if(self.prevLocation)
        {
                //計算本次定位數據與上次定位的時間差
            NSTimeInterval dTime = [currentLocation.timestamp
                                    timeIntervalSinceDate:self.prevLocation.timestamp];
                // 累計行車時間
            self.sumTime += dTime;
                // 計算本次定位數據與上次定位數據的距離
            CGFloat distance = [currentLocation distanceFromLocation:self.prevLocation];
                // 計算移動速度將米/秒換算成千米/小時需要乘以3.6
            CGFloat speed = distance / dTime * 3.6;

            NSLog(@"Speed : %f",speed);
                // 計算總平均速度
            alwaySpeed = self.sumDistance / self.sumTime * 3.6;
            //            NSLog(@"總平均速度%g公里",alwaySpeed);
            
                // 如果距離小於1米則忽略 直接返回該方法
            if(dTime < 1.0f)
            {
                return;
            }


            oldSpeed4 = oldSpeed3;
            oldSpeed3 = oldSpeed2;
            oldSpeed2 = _speed;
            
            if (speedBool == false)
            {
                oldSpeed = speed;
                speedBool = true;
            }
            else if (oldSpeed < 1.0)
            {
                oldSpeed = speed;
                NSLog(@"speed == 0");
            }
            //    NSLog(@"oldSpeed: %f",oldSpeed);
            else if (fabs(speed-oldSpeed) > 9)  // speed > oldSpeed+9 || speed < oldSpeed-9
            {
                if (fabs(oldSpeed4 - oldSpeed3) < 3 || fabs(oldSpeed3 - oldSpeed2) < 3 )
                {
                    oldSpeed = speed;
                    NSLog(@"oldSpeed = speed:%f",oldSpeed);
                } else {
                    NSLog(@"return");
                    return;
                }
            }
            oldSpeed = speed;
            

            

            
            // 累加移動距離
            self.sumDistance += distance;

                // 計算平均速度
            avgSpeed = self.sumDistance / self.sumTime * 3.6;
            allsumDistance = self.sumDistance / 1000;
            
            
            
            self.speedLabel.text = [NSString stringWithFormat:@" %i ", (int)speed];
            self.avgSpeedLabel.text = [NSString stringWithFormat:@" %i ", (int)avgSpeed];
            self.sumDistanceLabel.text = [NSString stringWithFormat:@" %.2f ", allsumDistance];
            self.alwaySpeedLabel.text = [NSString stringWithFormat:@" %.1f ", alwaySpeed];
            self.altitudeLabel.text = [NSString stringWithFormat:@"%.0f",currentLocation.altitude];

            //            NSLog(@"當前速度為%g公里/小時平均速度為:%g公里/小時。合計移動:%g公里",speed , avgSpeed , self.sumDistance / 1000);
            if (logupSpeed < speed) {
                logupSpeed = speed;
                self.upSpeedLabel.text = [NSString stringWithFormat:@" %i ", (int)logupSpeed];
            }
        }
        self.prevLocation = currentLocation;
    }
}



- (void) reverseGerocode {
    // 反查 Reverse Geocode
    // 可以只顯示在哪一區
    CLGeocoder *geocoder2 = [CLGeocoder new];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:25.032579
                                                      longitude:121.479553];
    
    [geocoder2 reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *placeMark;
        if (error) {
            NSLog(@"Geocode Fail: %@",error.description);
            return;
        } else if (placemarks!=nil && placemarks.count > 0) {
            placeMark = placemarks[0];
            NSDictionary *address = placeMark.addressDictionary;
            NSLog(@"Address: %@",address.description);
            
            NSLog(@"%@,%@,%@,%@,%@",placeMark.country,
                  placeMark.locality,placeMark.administrativeArea,
                  placeMark.thoroughfare,placeMark.subThoroughfare);
        }
     

        PFObject *mapLocation = [PFObject objectWithClassName:@"MapLocation"];
        mapLocation[@"currentLatitude"] = placeMark.locality;
        mapLocation[@"currentLongitude"] = placeMark.thoroughfare;
        mapLocation[@"userKeyPointer"] = [PFUser currentUser];

        NSLog(@"%@",[PFUser currentUser]);
        [mapLocation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                // The object has been saved.
                NSLog(@"location Save.");
                [mapLocation saveInBackground];
            } else {
                // There was a problem, check error.description
                NSLog(@"location failed");
            }
        }];
    }];
}





/*
- (void) distance {
    CLLocation *SourceLocation = [[CLLocation alloc] init];
    CLLocation *distinationLocation = [[CLLocation alloc] init];
    CGFloat totalDistance = 0.0;
    
    for (int i = 1; i < myLocationList.count ; i++) {
        
        SourceLocation = myLocationList[i-1];
        distinationLocation = myLocationList[i];
        
        CGFloat distance = [SourceLocation distanceFromLocation:distinationLocation];
//        NSLog(@"distance: %f",distance / 1000);
        totalDistance += distance;
    }
    NSLog(@"距離: %0.2f km",totalDistance / 1000);
}
*/


- (void) saveToSQLite {
    
    FMDatabase * db = [FMDatabase databaseWithPath:dbFileNamePath];
    if([db open]){
        //Prepare BLOB
        //        NSString * imagePath = [[NSBundle mainBundle]pathForResource:@"cat2.jpg" ofType:nil];
        //        NSData * imageData = [NSData dataWithContentsOfFile:imagePath];
        
        //Prepare DateTimeString
        //顯示localtime
        NSDateFormatter * formatter = [NSDateFormatter new];
        formatter.dateFormat = @"yyyy/MM/dd hh:mm:ss";
        formatter.timeZone = [NSTimeZone localTimeZone];
        NSString * localDateTimeString = [formatter stringFromDate:[NSDate date]];
//        NSString * datetimeString = [NSString stringWithFormat:@"%@_%d",localDateTimeString,arc4random()];
        //        NSString * datetimeString = [NSString stringWithFormat:@"%@_%d",[[NSDate date]description],arc4random()];
        
        NSString *avgSpeedSt = [NSString stringWithFormat:@"%.2f",avgSpeed];
        NSString *alwaySpeedSt = [NSString stringWithFormat:@"%.2f",alwaySpeed];
        NSString *uplogSpeedSt = [NSString stringWithFormat:@"%.2f",logupSpeed];
        NSString *sumDistanceSt = [NSString stringWithFormat:@"%.2f",_sumDistance/1000];
        NSData *datamyLocationList = [NSKeyedArchiver archivedDataWithRootObject:myLocationList];
        NSString *centerLatitude;
        if (maxLatitude > minLatitude) {
            centerLatitude = [NSString stringWithFormat:@"%f",(maxLatitude - minLatitude)];
        }else{
            centerLatitude = [NSString stringWithFormat:@"%f",(minLatitude - maxLatitude)];
        }
        NSLog(@"centerLatitude: %f,%f,%@",maxLatitude,minLatitude,centerLatitude);
        
        NSString *centerLongitude;
        if (maxLongitude > minLongitude) {
             centerLongitude = [NSString stringWithFormat:@"%f",(maxLongitude - minLongitude)];
        } else {
            centerLongitude = [NSString stringWithFormat:@"%f",(minLongitude - maxLongitude)];
        }
        NSLog(@"ceneterLongitude: %f,%f,%@",maxLongitude,minLongitude,centerLongitude);
        
        [db executeUpdate:@"INSERT INTO Mapsample_table (avgSpeed,alwaySpeed,allsumDistance,upSpeed,adddatetime,hour,minute,second,centerLatitude,centerLongitude,myLocationList) VALUES(?,?,?,?,?,?,?,?,?,?,?);",avgSpeedSt,alwaySpeedSt,sumDistanceSt,uplogSpeedSt,localDateTimeString,hour,minute,second,centerLatitude,centerLongitude,datamyLocationList];
        [db close];
    }
}



-(void)queryFileList{
    
    FMDatabase * db = [FMDatabase databaseWithPath:dbFileNamePath];
    if([db open]){
        FMResultSet * result = [db executeQuery:@"SELECT * FROM Mapsample_table;"];
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
            NSData * myLocationListdata = [result dataForColumn:@"myLocationList"];
            //image轉成imageData
            //            UIImage * image = [UIImage imageWithData:imageData];
            NSArray *myLocationListAr = [NSKeyedUnarchiver unarchiveObjectWithData:myLocationListdata];
            
            NSLog(@"%ld,%@,%@,%@,%@,%@,%@,%@,%@,%@",uid,avgSpeedNs,alwaySpeedNs,allsumDistanceNs,upSpeedNs,adddatetime,hour,minute,second,myLocationListAr);
            
            [_objects addObject:adddatetime];
        }
        [db close];
    }
}

-(NSMutableArray *)getFileList{
    
    NSMutableArray *fileList;
    // Prepare dbFileNamePath
    NSString * documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0];
    
    //stringByAppendingPathComponent 附加資料檔檔名sqlite.db
    NSString *dbFileNamePathForFileList = [documentsPath stringByAppendingPathComponent:@"Mapsqlite.db"];
    
    FMDatabase * db = [FMDatabase databaseWithPath:dbFileNamePathForFileList];
    if([db open]){
        FMResultSet * result = [db executeQuery:@"SELECT * FROM Mapsample_table;"];
        if(fileList == nil){
            fileList = [NSMutableArray new];
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
            NSData * myLocationListdata = [result dataForColumn:@"myLocationList"];
            //image轉成imageData
            //            UIImage * image = [UIImage imageWithData:imageData];
            NSArray *myLocationListAr = [NSKeyedUnarchiver unarchiveObjectWithData:myLocationListdata];
            
            NSLog(@"%ld,%@,%@,%@,%@,%@,%@,%@,%@,%@",uid,avgSpeedNs,alwaySpeedNs,allsumDistanceNs,upSpeedNs,adddatetime,hour,minute,second,myLocationListAr);
            

            [fileList addObject:@{@"id":[NSNumber numberWithInteger:uid],@"date":adddatetime}];
        }
        [db close];
    }
    
    return fileList;
}
- (IBAction)moveToMap:(id)sender {
//    [self performSegueWithIdentifier:@"goNavi" sender:sender ];
//    [self segue];
    
    if (myLocationList != nil) {
//        NSLog(@"myLocationList == nil");
//        [self showViewController:navi sender:nil];
//    } else {
        NSLog(@"!= nil");
        [self showViewController:navi sender:self];
    }
}

- (void) segue {
    navi = [self.storyboard instantiateViewControllerWithIdentifier:@"NaviViewController"];
    navi.locationArray = myLocationList;
}

- (IBAction)dismissMap:(id)sender {
    [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
}

-(void)timer{
}

//
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    myLocationList = (NSMutableArray*)sender;
//    
//    if ([[segue identifier] isEqualToString:@"goNavi"]) {
//        
//        NaviViewController *navi = (NaviViewController*)segue.destinationViewController;
//        navi.locationArray = myLocationList;
//    }
//    
//}



@end
