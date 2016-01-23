//
//  ViewController.h
//  iamvegan
//
//  Created by Ian MacKinnon on 2016-01-22.
//  Copyright © 2016 Ian MacKinnon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VeganHelper.h"

@interface ViewController : UIViewController


@property(nonatomic, strong) IBOutlet UIImageView *profileView;
@property(nonatomic, strong) IBOutlet UIButton *veganButton;
@property(nonatomic, strong) IBOutlet UILabel *buttonLabel;
@property(nonatomic, strong) CBCentralManager *bluetoothManager;

-(IBAction)veganAction:(id)sender;

-(IBAction)clear:(id)sender;

-(IBAction)testNotification:(id)sender;


@end

