//
//  ViewController.h
//  iamvegan
//
//  Created by Ian MacKinnon on 2016-01-22.
//  Copyright © 2016 Ian MacKinnon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VeganHelper.h"

@interface ViewController : UIViewController<CLLocationManagerDelegate>


@property(nonatomic, strong) IBOutlet UISwitch *onSwitch;

@property(nonatomic, strong) IBOutlet UIImageView *profileView;
@property(nonatomic, strong) IBOutlet UILabel *nameLabel;
@property(nonatomic, strong) CBCentralManager *bluetoothManager;

-(IBAction)toggleSwitch:(id)sender;
-(IBAction)clear:(id)sender;


@end

