//
//  DetailViewController.h
//  GetRide
//
//  Created by 余佳恆 on 2015/11/26.
//  Copyright © 2015年 CHIA HENG YU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController
@property NSMutableArray *objects;
@property (nonatomic,strong) NSNumber * routeID;
- (IBAction)shareWithFacebookButtonPressed:(id)sender;
@end
