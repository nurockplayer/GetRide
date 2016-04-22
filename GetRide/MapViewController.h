//
//  MapViewController.h
//  GetRideSwift
//
//  Created by 余佳恆 on 2015/11/16.
//  Copyright © 2015年 CHIA HENG YU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <Bolts/Bolts.h>
#import <FMDatabase.h>

@class DetailViewController;

@interface MapViewController : UIViewController
{

}
@property (strong, nonatomic) DetailViewController *detailViewController;
@property NSMutableArray *objects;


- (void)queryFileList;
- (NSMutableArray*)getFileList;

@end
